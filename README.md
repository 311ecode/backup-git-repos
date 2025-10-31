# backupGitRepo

A lightweight Bash utility for creating timestamped backups of a Git
repository. Designed to be simple, space-efficient, and Git-aware.

## ✨ Features

- 📦 Creates timestamped backup directories alongside your repository  
- 🧹 Skips files and directories that are ignored by Git (`.gitignore`)  
- 🔄 Automatically enforces a maximum number of retained backups  
- 🏷️ Optional identifier labels for backup organization
- 🛠 Pure Bash with no external dependencies beyond Git and rsync  

## 📂 Project Structure

```
util/backup/backupGitRepo/
├── src/
│   └── backupGitRepo.sh          # Main implementation
├── test/
│   └── backupGitRepo_test.sh     # Test suite
└── README.md                     # This file
```

## 🚀 Usage

### Run a backup

```bash
backupGitRepo [maxBackups] [identifier]
```

* `maxBackups` – **Optional** number of backups to keep (oldest are deleted). If provided, must be first parameter and a number.
* `identifier` – **Optional** label to add to backup filename for organization.

### Usage Examples

```bash
# Keep 5 most recent backups
backupGitRepo 5

# Keep 3 most recent backups with identifier
backupGitRepo 3 release-candidate

# Create backup with identifier only (no cleanup)
backupGitRepo feature-branch

# Create basic backup (no cleanup, no identifier)
backupGitRepo
```

### Output Examples

```
📦 Creating backup: myrepo-2025-08-21-11-30-45-release-candidate
✅ Backup created at /home/user/projects/myrepo-2025-08-21-11-30-45-release-candidate
🗑️ Removed oldest backup: myrepo-2025-08-19-09-12-00
```

Backups are created one directory above your repository root:

```
myrepo/
myrepo-2025-08-21-11-30-45-release-candidate/
myrepo-2025-08-20-14-02-11-feature-branch/
myrepo-2025-08-19-09-12-00/
```

## 🧹 Git-ignore Aware

Unlike naive copy scripts, `backupGitRepo` respects `.gitignore`:

* Ignored files (like `node_modules/`, `*.log`, `dist/`) are **not included** in backups by default.
* This keeps backups small and focused on meaningful project files.

### Including Ignored Files

To include ignored files in your backup, set the `KEEP_IGNORED_REPO` environment variable:

```bash
# Include all files, even those in .gitignore
KEEP_IGNORED_REPO=1 backupGitRepo

# Works with other parameters too
KEEP_IGNORED_REPO=1 backupGitRepo 5 full-backup
```

## 🧪 Tests

Run the test suite:

```bash
testBackupGitRepo
```

Currently covered:

* ✅ Backup directory creation
* ✅ Git-ignore exclusion behavior
* ✅ Maximum backup count enforcement
* ✅ Identifier parameter handling
* ✅ Flexible parameter parsing
* ✅ KEEP_IGNORED_REPO environment variable

## 📜 License

Copyright © 2025 Imre Toth
Proprietary Software – See `LICENSE` file for terms.
