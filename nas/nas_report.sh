#!/bin/bash
# File: /usr/local/bin/nas_report.sh
# Purpose: Consolidated NAS reporting script
# Logs go to /var/log/nas_report.log

LOG_FILE="/var/log/nas_report.log"

echo "=== NAS Report $(date) ===" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# --- Pool status ---
#
echo "=== Pool Status ===" >> "$LOG_FILE"
POOL_DETAILS=$(zfs list)
/usr/local/bin/nas_event_report.sh pool_report "$POOL_DETAILS" >> "$LOG_FILE" 2>&1
echo "" >> "$LOG_FILE"

# --- Snapshot status ---
#
echo "=== Snapshot Status (last 5 @nas snapshots) ===" >> "$LOG_FILE"
SNAPSHOT_DETAILS=$(zfs list -t snapshot | grep @nas | tail -5)
/usr/local/bin/nas_event_report.sh snapshot_report "$SNAPSHOT_DETAILS" >> "$LOG_FILE" 2>&1
echo "" >> "$LOG_FILE"

# Optional: add more sections here in the future
#


