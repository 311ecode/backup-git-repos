#!/usr/bin/env bash
# Copyright © 2025 Imre Toth
# Proprietary Software. See LICENSE file for terms.

# @file backupGitRepo_test.sh
# @brief Test suite for backupGitRepo
# @description Tests core backup behavior, node_modules cleanup,
#              and maxBackups enforcement.

testBackupGitRepo() {
  export LC_NUMERIC=C

  testBackupGitRepoCreatesBackupDirectory() {
    echo "🧪 Should create a backup directory"
    local tempDir
    tempDir=$(mktemp -d)
    cd "$tempDir"

    git init -q testrepo
    cd testrepo
    echo "content" > file.txt
    git add file.txt && git commit -q -m "init"

    mkdir node_modules && touch node_modules/fake.js

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

  testBackupGitRepoRemovesNodeModules() {
    echo "🧪 Should remove node_modules in backup"
    local tempDir
    tempDir=$(mktemp -d)
    cd "$tempDir"

    git init -q testrepo
    cd testrepo
    mkdir -p node_modules && touch node_modules/fake.js
    git add . && git commit -q -m "init"

    getTheRootOfTheGitRepository() {
      git rev-parse --show-toplevel
    }

    backupGitRepo 1 >/dev/null
    cd ..
    local backupDir
    backupDir=$(ls -d testrepo-* | head -n 1)

    if [[ ! -d "$backupDir/node_modules" ]]; then
      echo "✅ node_modules removed in backup"
      return 0
    else
      echo "❌ ERROR: node_modules still exists in backup"
      return 1
    fi
  }

  testBackupGitRepoMaxBackupsEnforced() {
    echo "🧪 Should enforce maxBackups"
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

  local test_functions=(
    "testBackupGitRepoCreatesBackupDirectory"
    "testBackupGitRepoRemovesNodeModules"
    "testBackupGitRepoMaxBackupsEnforced"
  )

  local ignored_tests=()

  bashTestRunner test_functions ignored_tests
  return $?
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  testBackupGitRepo
fi