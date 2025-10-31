#!/usr/bin/env bash
testBackupGitRepo() {
  export LC_NUMERIC=C

  testBackupGitRepoCreatesBackupDirectory() {
    echo "🧪 testBackupGitRepoCreatesBackupDirectory"
    local tempDir
    tempDir=$(mktemp -d)
    cd "$tempDir"

    git init -q testrepo
    cd testrepo
    echo "content" > file.txt
    git add file.txt && git commit -q -m "init"

    # Stub getTheRootOfTheGitRepository
    getTheRootOfTheGitRepository() {
      git rev-parse --show-toplevel
    }

    backupGitRepo 1 >/dev/null

    cd ..
    local backupCount
    backupCount=$(ls -d testrepo-* | wc -l)

    if [[ "$backupCount" -eq 1 ]]; then
      echo "✅ Backup directory created"
      return 0
    else
      echo "❌ ERROR: Expected 1 backup, got $backupCount"
      return 1
    fi
  }
  
  testBackupGitRepoExcludesIgnoredDirectory() {
    echo "🧪 testBackupGitRepoExcludesIgnoredDirectory (Fixing node_modules failure)"
    local tempDir
    tempDir=$(mktemp -d)
    cd "$tempDir"

    git init -q testrepo
    cd testrepo
    
    # 1. Set up ignore rule
    echo "node_modules/" > .gitignore
    git add .gitignore && git commit -q -m "Add gitignore"
    
    # 2. Create the ignored directory and file
    mkdir -p node_modules/deps
    echo "ignored data" > node_modules/deps/junk.file
    
    # Sanity check: ensure Git considers it ignored (ls-files -i will list it)
    if ! git ls-files --others --ignored --exclude-standard 2>/dev/null | grep -q 'node_modules/deps/junk.file'; then
      echo "❌ Setup Error: Ignored files are not being detected by git ls-files"
      return 1
    fi
    
    getTheRootOfTheGitRepository() {
      git rev-parse --show-toplevel
    }

    # Run backup (no params, cleanup is not the focus here)
    backupGitRepo >/dev/null

    cd ..
    local latestBackupDir
    latestBackupDir=$(ls -d testrepo-* | sort | tail -n 1)

    # Check if ignored directory/file is NOT present in backup
    if [[ ! -d "$latestBackupDir/node_modules" ]]; then
      echo "✅ Ignored directory (node_modules) was correctly excluded"
      return 0
    else
      echo "❌ ERROR: Ignored directory 'node_modules' was found in backup: $latestBackupDir"
      return 1
    fi
  }

  testBackupGitRepoMaxBackupsEnforced() {
    echo "🧪 testBackupGitRepoMaxBackupsEnforced"
    local tempDir
    tempDir=$(mktemp -d)
    cd "$tempDir"

    git init -q testrepo
    cd testrepo
    echo "data" > file.txt
    git add file.txt && git commit -q -m "init"

    getTheRootOfTheGitRepository() {
      git rev-parse --show-toplevel
    }

    backupGitRepo 2 >/dev/null
    sleep 1
    backupGitRepo 2 >/dev/null
    sleep 1
    backupGitRepo 2 >/dev/null

    cd ..
    local backupCount
    backupCount=$(ls -d testrepo-* | wc -l)

    if [[ "$backupCount" -eq 2 ]]; then
      echo "✅ maxBackups enforced"
      return 0
    else
      echo "❌ ERROR: Expected 2 backups, got $backupCount"
      return 1
    fi
  }

  testBackupGitRepoWithIdentifier() {
    echo "🧪 testBackupGitRepoWithIdentifier"
    local tempDir
    tempDir=$(mktemp -d)
    cd "$tempDir"

    git init -q testrepo
    cd testrepo
    echo "content" > file.txt
    git add file.txt && git commit -q -m "init"

    getTheRootOfTheGitRepository() {
      git rev-parse --show-toplevel
    }

    # Test with maxBackups and identifier
    backupGitRepo 1 "test-label" >/dev/null

    cd ..
    local backupFound
    backupFound=$(ls -d testrepo-*-test-label 2>/dev/null | wc -l)

    if [[ "$backupFound" -eq 1 ]]; then
      echo "✅ Backup with identifier created"
      return 0
    else
      echo "❌ ERROR: Expected backup with identifier 'test-label'"
      return 1
    fi
  }

  testBackupGitRepoIdentifierOnly() {
    echo "🧪 testBackupGitRepoIdentifierOnly"
    local tempDir
    tempDir=$(mktemp -d)
    cd "$tempDir"

    git init -q testrepo
    cd testrepo
    echo "content" > file.txt
    git add file.txt && git commit -q -m "init"

    getTheRootOfTheGitRepository() {
      git rev-parse --show-toplevel
    }

    # Test with identifier only (no maxBackups)
    backupGitRepo "standalone-label" >/dev/null

    cd ..
    local backupFound
    backupFound=$(ls -d testrepo-*-standalone-label 2>/dev/null | wc -l)

    if [[ "$backupFound" -eq 1 ]]; then
      echo "✅ Identifier-only parameter works"
      return 0
    else
      echo "❌ ERROR: Expected backup with identifier 'standalone-label'"
      return 1
    fi
  }

  testBackupGitRepoNoParameters() {
    echo "🧪 testBackupGitRepoNoParameters"
    local tempDir
    tempDir=$(mktemp -d)
    cd "$tempDir"

    git init -q testrepo
    cd testrepo
    echo "content" > file.txt
    git add file.txt && git commit -q -m "init"

    getTheRootOfTheGitRepository() {
      git rev-parse --show-toplevel
    }

    # Test with no parameters
    backupGitRepo >/dev/null

    cd ..
    local backupCount
    backupCount=$(ls -d testrepo-* | wc -l)

    if [[ "$backupCount" -eq 1 ]]; then
      echo "✅ No parameters works correctly"
      return 0
    else
      echo "❌ ERROR: Expected 1 backup with no parameters, got $backupCount"
      return 1
    fi
  }

  testBackupGitRepoKeepsIgnoredFiles() {
    echo "🧪 testBackupGitRepoKeepsIgnoredFiles"
    local tempDir
    tempDir=$(mktemp -d)
    cd "$tempDir"

    git init -q testrepo
    cd testrepo
    
    # Create git-ignored directory/file
    echo "*.log" > .gitignore
    echo "LOG DATA" > app.log
    
    # Confirm file is ignored by git
    if ! git ls-files --others --ignored --exclude-standard 2>/dev/null | grep -q 'app.log'; then
      echo "❌ Setup Error: app.log is not ignored by git"
      return 1
    fi

    getTheRootOfTheGitRepository() {
      git rev-parse --show-toplevel
    }

    # Run backup with KEEP_IGNORED_REPO set
    export KEEP_IGNORED_REPO=true
    backupGitRepo >/dev/null
    unset KEEP_IGNORED_REPO # Unset for other tests

    cd ..
    local latestBackupDir
    latestBackupDir=$(ls -d testrepo-* | sort | tail -n 1)

    # Check if ignored file is present in backup
    if [[ -f "$latestBackupDir/app.log" ]]; then
      echo "✅ Ignored file kept in backup when KEEP_IGNORED_REPO is set"
      return 0
    else
      echo "❌ ERROR: Ignored file 'app.log' was NOT found in backup: $latestBackupDir"
      return 1
    fi
  }

  local test_functions=(
    "testBackupGitRepoCreatesBackupDirectory"
    "testBackupGitRepoExcludesIgnoredDirectory" # New test for exclusion
    "testBackupGitRepoMaxBackupsEnforced"
    "testBackupGitRepoWithIdentifier"
    "testBackupGitRepoIdentifierOnly"
    "testBackupGitRepoNoParameters"
    "testBackupGitRepoKeepsIgnoredFiles"
  )

  local ignored_tests=()

  bashTestRunner test_functions ignored_tests
  return $?
}