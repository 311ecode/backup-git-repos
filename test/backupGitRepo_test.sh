#!/usr/bin/env bash
# Copyright © 2025 Imre Toth
# Proprietary Software. See LICENSE file for terms.

# @file backupGitRepo_test.sh
# @brief Test suite for backupGitRepo
# @description Tests backup creation and maxBackups enforcement.

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

  local test_functions=(
    "testBackupGitRepoCreatesBackupDirectory"
    "testBackupGitRepoMaxBackupsEnforced"
    "testBackupGitRepoWithIdentifier"
    "testBackupGitRepoIdentifierOnly"
    "testBackupGitRepoNoParameters"
  )

  local ignored_tests=()

  bashTestRunner test_functions ignored_tests
  return $?
}