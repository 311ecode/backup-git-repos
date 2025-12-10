#!/usr/bin/env bash
# Copyright © 2025 Imre Toth <tothimre@gmail.com>
# Proprietary Software. See LICENSE file for terms.

backupGitRepo() {
  command -v markdown-show-help-registration &>/dev/null && eval "$(markdown-show-help-registration)"

  local maxBackups
  local identifier
  
  # Parse parameters: if first param is a number, it's maxBackups
  if [[ $1 =~ ^[0-9]+$ ]]; then
    maxBackups=$1
    identifier=$2
  else
    # First param is not a number, treat it as identifier
    maxBackups=""
    identifier=$1
  fi

  local oldPWD=$(pwd)
  local repoRoot
  repoRoot=$(getTheRootOfTheGitRepository)

  # --- DEBUGGING START ---
  if [[ -n "$DEBUG" ]]; then
    echo "DEBUG: Repository Root: $repoRoot"
  fi
  # --- DEBUGGING END ---

  local repoName
  repoName=$(basename "$repoRoot")
  local backupDate
  backupDate=$(date +%Y-%m-%d)
  local backupTime
  backupTime=$(date +%H-%M-%S)

  cd "$repoRoot/.." || return 1

  # Construct backup name with optional identifier
  local backupName="$repoName-$backupDate-$backupTime"
  if [[ -n "$identifier" ]]; then
    backupName="$backupName-$identifier"
  fi

  mkdir "$backupName"

  echo "📦 Creating backup: $backupName"

  local excludeArgs=()
  # Check if KEEP_IGNORED_REPO is NOT set; if so, apply git-ignore logic
  if [[ -z "${KEEP_IGNORED_REPO}" ]]; then
    # Collect ignored files from git
    local ignoredList
    ignoredList=$(git -C "$repoRoot" status --porcelain --ignored \
      2>/dev/null | grep '^!!' | cut -c4-)

    # --- DEBUGGING START ---
    if [[ -n "$DEBUG" ]]; then
      echo "DEBUG: Parsed ignoredList for rsync exclusion:"
      echo "$ignoredList"
    fi
    # --- DEBUGGING END ---

    while IFS= read -r relPath; do
      [[ -z "$relPath" ]] && continue
      excludeArgs+=(--exclude="$relPath")
    done <<< "$ignoredList"

  else
    echo "⚠️ KEEP_IGNORED_REPO is set. All files (including ignored ones) will be backed up."
  fi

  # --- DEBUGGING START ---
  if [[ -n "$DEBUG" ]]; then
    echo "DEBUG: Exclude arguments:"
    printf '%s\n' "${excludeArgs[@]}"
  fi
  # --- DEBUGGING END ---

  # Copy repo → backup, skipping ignored files (unless KEEP_IGNORED_REPO is set)
  rsync -a --quiet "${excludeArgs[@]}" \
    "$repoName/" "$backupName/"

  local backupPath
  backupPath="$(realpath "$backupName")"
  echo "✅ Backup created at $backupPath"

  # Set environment variable for the latest backup path
  export LAST_BACKUP="$backupPath"
  echo "🔗 LAST_BACKUP set to $LAST_BACKUP"

  # Enforce maxBackups limit (only if maxBackups is a number > 0)
  if [[ -n $maxBackups && $maxBackups =~ ^[0-9]+$ && $maxBackups -gt 0 ]]; then
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
