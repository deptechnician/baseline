#!/bin/bash

# ==============================
# SCRIPT 1: Create Snapshot
# ==============================

SNAP_DATE=$(date +%Y-%m-%d)
SNAP_NAME="nas@${SNAP_DATE}"
EVENT_STATUS="success"

echo "Creating recursive snapshot: $SNAP_NAME"

# Create recursive snapshot
if sudo zfs snapshot -r "$SNAP_NAME"; then
    echo "Snapshot created successfully."
else
    EVENT_STATUS="failed"
    echo "Snapshot FAILED."
fi

# Report creation status to n8n
sudo /usr/local/bin/nas_event_report.sh \
    "snapshot" \
    "Snapshot ${SNAP_NAME} created: ${EVENT_STATUS}"

# Call delta calculation script
/usr/local/bin/nas_snapshot_stats.sh "$SNAP_NAME"
