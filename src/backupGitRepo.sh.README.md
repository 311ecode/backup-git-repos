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

### Environment Variables

- **KEEP_IGNORED_REPO** (optional, boolean)  
  When set to any value (e.g., `true` or `1`), includes Git-ignored files in the backup.  
  Default behavior excludes files matching `.gitignore` patterns.  
  - **Usage**: `export KEEP_IGNORED_REPO=true`

- **DEBUG** (optional, boolean)  
  Enables verbose debugging output showing rsync exclusion logic and repository paths.  
  - **Usage**: `export DEBUG=true`

## Usage Examples

### Basic Backup (No Parameters)
```bash
backupGitRepo
```
Creates a single timestamped backup (e.g., `myrepo-2025-01-15-14-30-45`) with Git-ignored files excluded.

### Backup with Retention Policy
```bash
backupGitRepo 3
```
Creates a backup and ensures only the 3 most recent backups are kept (automatically deletes older ones).

### Backup with Custom Identifier
```bash
backupGitRepo "before-refactor"
```
Creates a backup with identifier label (e.g., `myrepo-2025-01-15-14-30-45-before-refactor`).

### Combined Usage
```bash
backupGitRepo 5 "production-backup"
```
Creates an identified backup while maintaining a maximum of 5 backups.

### Include Ignored Files
```bash
export KEEP_IGNORED_REPO=true
backupGitRepo 2
unset KEEP_IGNORED_REPO
```
Creates a backup including `node_modules`, build artifacts, and other Git-ignored files, keeping only 2 backups.

## Detailed Information

### Backup Naming Convention
Backups follow the pattern:  
`<repository-name>-<YYYY-MM-DD>-<HH-MM-SS>[-<identifier>]`

Example: `myproject-2025-01-15-14-30-45-pre-deploy`

### File Exclusion Logic
By default, the script:
1. Uses `git status --porcelain --ignored` to detect ignored files
2. Passes excluded paths to `rsync` with `--exclude` arguments
3. Skips all files and directories matching `.gitignore` patterns

When `KEEP_IGNORED_REPO` is set, all files are copied regardless of Git ignore rules.

### Retention Management
- Backups are sorted by name (lexicographically, which works with timestamp format)
- Only backups matching the pattern `<repo-name>-*` are considered
- Oldest backups are deleted first when exceeding `maxBackups`
- The cleanup happens **after** creating the new backup

### Dependencies
- `git` - Must be installed and repository must be initialized
- `rsync` - Used for efficient file copying
- `getTheRootOfTheGitRepository` - Helper function to find repository root

### Error Handling
- Returns to original directory even if errors occur
- Validates numeric parameters
- Handles missing dependencies gracefully

### Testing
The function includes comprehensive test coverage verifying:
- Backup creation with various parameter combinations
- Git-ignore exclusion behavior
- Retention policy enforcement
- Identifier functionality

### Performance Considerations
- Uses `rsync -a` for efficient incremental-like copying
- Minimal overhead for small to medium repositories
- Cleanup operations are O(n) where n is number of existing backups

## Notes
- Run from anywhere within a Git repository
- Backups are created in the parent directory of the repository
- The `.git` directory is included in backups
- Timestamp uses system local time
- Works with nested Git repositories (uses `git rev-parse --show-toplevel`)
