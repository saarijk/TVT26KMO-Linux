#!/usr/bin/env bash
set -euo pipefail

# Configuration
SOURCE="/var/www/html/"
TIMESTAMP="$(date '+%Y-%m-%d_%H%M%S')"
REMOTE_USER="backupuser"
REMOTE_HOST="SERVER_B_IP"
REMOTE_BASE="/var/backups/website"
REMOTE_DIR="${REMOTE_BASE}/html-${TIMESTAMP}"
SSH_KEY="/home/backupuser/.ssh/backup_key"
LOG_FILE="/var/log/website-backup.log"

# Ensure log file is writable
touch "$LOG_FILE" 2>/dev/null || LOG_FILE="/tmp/website-backup.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting backup to ${REMOTE_DIR}" >> "$LOG_FILE"

# Execute rsync
if rsync -az --delete \
    -e "ssh -i ${SSH_KEY} -o StrictHostKeyChecking=yes" \
    "$SOURCE" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/" >> "$LOG_FILE" 2>&1; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: Backup completed" >> "$LOG_FILE"
    exit 0
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] FAILED: rsync exited with error" >> "$LOG_FILE"
    exit 1
fi