#!/usr/bin/env bash
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