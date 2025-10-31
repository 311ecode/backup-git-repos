#!/usr/bin/env bash
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