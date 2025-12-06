#!/bin/bash

# ==============================
# SCRIPT 1: Create Snapshot
# ==============================

LOG_FILE="/var/log/nas_snapshot.log"
SNAP_DATE=$(date +%Y-%m-%d)
SNAP_NAME="nas@${SNAP_DATE}"
EVENT_STATUS="success"

{
    echo "=== Snapshot Run $(date) ==="
    echo "Creating recursive snapshot: $SNAP_NAME"

    # Create recursive snapshot
    if sudo zfs snapshot -r "$SNAP_NAME"; then
        echo "Snapshot created successfully."
    else
        EVENT_STATUS="failed"
        echo "Snapshot FAILED."
    fi

    # Call delta calculation script if snapshot succeeded
    # if [ "$EVENT_STATUS" = "success" ]; then
    #    /usr/local/bin/nas_snapshot_stats.sh "$SNAP_NAME"
    # fi

    echo ""  # extra line for readability
} >> "$LOG_FILE" 2>&1
