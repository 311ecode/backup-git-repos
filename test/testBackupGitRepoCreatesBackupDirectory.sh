#!/usr/bin/env bash
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