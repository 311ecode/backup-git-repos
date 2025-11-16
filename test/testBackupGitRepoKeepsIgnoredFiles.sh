#!/usr/bin/env bash
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
