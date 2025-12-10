# backupGitRepo - Git Repository Backup Utility

Creates timestamped backups of Git repositories with optional retention policies and identifier tagging.

## Parameters

### Positional Parameters

1. **maxBackups** (optional, integer)
   Maximum number of backups to keep. When specified as the first parameter (must be a number), the script will automatically clean up older backups to maintain this limit.
   - **Type**: Positive integer
   - **Example**: `5` (keeps only the 5 most recent backups)

2. **identifier** (optional, string)
   Custom label appended to backup directory names for easier identification. Can be used with or without `maxBackups`.
   - **Type**: Alphanumeric string (no spaces recommended)
   - **Example**: `"pre-deploy"` or `"v2.1-backup"`

### Environment Variables (Input)

- **KEEP_IGNORED_REPO** (optional, boolean)
  When set to any value (e.g., `true` or `1`), includes Git-ignored files in the backup.
  Default behavior excludes files matching `.gitignore` patterns.
  - **Usage**: `export KEEP_IGNORED_REPO=true`

- **DEBUG** (optional, boolean)
  Enables verbose debugging output showing rsync exclusion logic and repository paths.
  - **Usage**: `export DEBUG=true`

### Environment Variables (Output)

- **LAST_BACKUP** (output, string)
  **Set and exported by the function** to the absolute path of the newly created backup directory. This variable is available for subsequent commands in the same shell session (if the function is sourced).
  - **Value**: `/absolute/path/to/myproject-2025-01-15-14-30-45`
  - **Usage**: Can be immediately referenced, e.g., `echo "Latest backup is in $LAST_BACKUP"`

## Usage Examples

### Basic Backup (No Parameters)
```bash
backupGitRepo
