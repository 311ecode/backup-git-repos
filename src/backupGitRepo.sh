#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com> - Proprietary Software. See LICENSE file for terms.
backupGitRepo() {
  local maxBackups=$1
  local oldPWD=$(pwd)
  local theRootOfTheGitRepository=$(getTheRootOfTheGitRepository)

  local theDirectoryNameOfTheOldPWD=$(basename "$theRootOfTheGitRepository")
  local backupDate=$(date +%Y-%m-%d)
  local backupTime=$(date +%H-%M-%S)

  # Change to the parent directory of the git repository
  cd "$theRootOfTheGitRepository/.."

  local backupName="$theDirectoryNameOfTheOldPWD-$backupDate-$backupTime"
  cp -r "$theDirectoryNameOfTheOldPWD" "$backupName"

  # Change into the newly created backup directory
  cd "$backupName"

  local backupPath="$(pwd)"
  echo "The path of the backup directory is $backupPath"
  echo "Removing node_modules folders from $backupPath"
  find . -name 'node_modules' -type d -prune -exec rm -rf {} +

  # Return to the parent directory
  cd ..

  # Remove oldest backups if maxBackups is defined and exceeded
  if [[ -n $maxBackups && $maxBackups -gt 0 ]]; then
    local backupCount=$(ls -d "$theDirectoryNameOfTheOldPWD"-* 2>/dev/null | wc -l)
    while [[ $backupCount -gt $maxBackups ]]; do
      local oldestBackup=$(ls -d "$theDirectoryNameOfTheOldPWD"-* | sort | head -n 1)
      rm -rf "$oldestBackup"
      echo "Removed oldest backup: $oldestBackup"
      backupCount=$((backupCount - 1))
    done
  fi

  # Return to the original directory
  cd "$oldPWD"
}
