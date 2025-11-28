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
echo "=== Snapshot Status (most recent NAS snapshot) ===" >> "$LOG_FILE"

# Get the most recent snapshot name containing @nas
LATEST_SNAP=$(zfs list -t snapshot -o name -s creation | tail -1 | awk -F@ '{print $2}')
SNAPSHOT_DETAILS=$(zfs list -t snapshot -o name,used,refer | grep "$LATEST_SNAP")

# Get the latest 3 snapshots of the 'nas' dataset, ordered by creation date
SNAPSHOT_MESSAGE=$(fs list nas -t snapshot -o name -s creation | tail -3 | tr '\n' ' ')

# Send all snapshot details in a single event to NAS monitor
/usr/local/bin/nas_report_event.sh snapshot_report "$SNAPSHOT_MESSAGE" >> "$LOG_FILE" 2>&1
/usr/local/bin/nas_report_system_stats.sh 

# Also print to log for local reference
echo "$SNAPSHOT_DETAILS" >> "$LOG_FILE"
echo "$SNAPSHOT_MESSAGE" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"


