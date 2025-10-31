#!/usr/bin/env bash
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