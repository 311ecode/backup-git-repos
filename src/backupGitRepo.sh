#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com>
# Proprietary Software. See LICENSE file for terms.

backupGitRepo() {
  local maxBackups=$1
  local oldPWD=$(pwd)
  local repoRoot
  repoRoot=$(getTheRootOfTheGitRepository)

  local repoName
  repoName=$(basename "$repoRoot")
  local backupDate
  backupDate=$(date +%Y-%m-%d)
  local backupTime
  backupTime=$(date +%H-%M-%S)

  cd "$repoRoot/.." || return 1

  local backupName="$repoName-$backupDate-$backupTime"
  mkdir "$backupName"

  echo "📦 Creating backup: $backupName"

  # Collect ignored files from git
  local ignoredList
  ignoredList=$(git -C "$repoRoot" status --porcelain --ignored \
    2>/dev/null | grep '^!!' | cut -c4-)

  local excludeArgs=()
  while IFS= read -r relPath; do
    [[ -z "$relPath" ]] && continue
    excludeArgs+=(--exclude="$relPath")
  done <<< "$ignoredList"

  # Copy repo → backup, skipping ignored files
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
