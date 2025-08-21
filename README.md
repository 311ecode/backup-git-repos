# backupGitRepo

A lightweight Bash utility for creating timestamped backups of a Git
repository. Designed to be simple, space-efficient, and Git-aware.

## ✨ Features

- 📦 Creates timestamped backup directories alongside your repository  
- 🧹 Skips files and directories that are ignored by Git (`.gitignore`)  
- 🔄 Automatically enforces a maximum number of retained backups  
- 🛠 Pure Bash with no external dependencies beyond Git and rsync  

## 📂 Project Structure

```

util/backup/backupGitRepo/
├── src/
│   └── backupGitRepo.sh          # Main implementation
├── test/
│   └── backupGitRepo\_test.sh     # Test suite
└── README.md                     # This file

````

## 🚀 Usage


### 2. Run a backup

```bash
backupGitRepo <maxBackups>
```

* `<maxBackups>` – Number of backups to keep (oldest are deleted).
  Example: `backupGitRepo 5` keeps only the 5 most recent backups.

### 3. Example

```bash
cd ~/projects/myrepo
backupGitRepo 3
```

Output:

```
📦 Creating backup: myrepo-2025-08-21-11-30-45
✅ Backup created at /home/user/projects/myrepo-2025-08-21-11-30-45
🗑️ Removed oldest backup: myrepo-2025-08-19-09-12-00
```

Backups are created one directory above your repository root:

```
myrepo/
myrepo-2025-08-21-11-30-45/
myrepo-2025-08-20-14-02-11/
```

## 🧹 Git-ignore Aware

Unlike naive copy scripts, `backupGitRepo` respects `.gitignore`:

* Ignored files (like `node_modules/`, `*.log`, `dist/`) are **not
  included** in backups.
* This keeps backups small and focused on meaningful project files.

## 🧪 Tests

Run the test suite:

```bash
testBackupGitRepo
```

Currently covered:

* ✅ Backup directory creation
* ✅ Maximum backup count enforcement

## 📜 License

Copyright © 2025 Imre Toth
Proprietary Software – See `LICENSE` file for terms.