#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com>
# Proprietary Software. See LICENSE file for terms.

backupGitRepo() {
  local maxBackups=$1
  local oldPWD=$(pwd)
  local repoRoot
  repoRoot=$(getTheRootOfTheGitRepository)

  local repoName=$(basename "$repoRoot")
  local backupDate=$(date +%Y-%m-%d)
  local backupTime=$(date +%H-%M-%S)

  cd "$repoRoot/.." || return 1

  local backupName="$repoName-$backupDate-$backupTime"
  mkdir "$backupName"

  echo "📦 Creating backup: $backupName"

  # Get ignored files (absolute paths)
  local ignoredList
  ignoredList=$(git_list_ignored_files "$repoRoot")

  local excludeArgs=()
  while IFS= read -r absPath; do
    [[ -z "$absPath" ]] && continue
    # Convert absolute → relative to repoRoot
    local relPath="${absPath#$repoRoot/}"
    excludeArgs+=(--exclude="$relPath")
  done <<< "$ignoredList"

  rsync -a --quiet "${excludeArgs[@]}" \
    "$repoName/" "$backupName/"

  local backupPath
  backupPath="$(realpath "$backupName")"
  echo "✅ Backup created at $backupPath"

  # Enforce maxBackups limit
  if [[ -n $maxBackups && $maxBackups -gt 0 ]]; then
    local backupCount
    backupCount=$(ls -d "$repoName"-* 2>/dev/null | wc -l)
    while [[ $backupCount -gt $maxBackups ]]; do
      local oldestBackup
      oldestBackup=$(ls -d "$repoName"-* | sort | head -n 1)
      rm -rf "$oldestBackup"
      echo "🗑️ Removed oldest backup: $oldestBackup"
      backupCount=$((backupCount - 1))
    done
  fi

  cd "$oldPWD" || return 1
}
