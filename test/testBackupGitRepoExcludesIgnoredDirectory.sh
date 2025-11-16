#!/usr/bin/env bash
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
