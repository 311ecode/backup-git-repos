#!/usr/bin/env bash
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
