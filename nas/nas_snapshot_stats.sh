#!/bin/bash

# ==============================
# SCRIPT 2: Size Delta Reporter
# ==============================

SNAP_NAME="$1"  # Passed from the first script
SNAP_DATE="${SNAP_NAME#nas@}"  # Extract YYYY-MM-DD

TOTAL_DIFF=0
DATASET_CHANGES=()

echo "Calculating delta for snapshot: $SNAP_NAME"

# Loop through all sub-datasets under nas
for DATASET in $(sudo zfs list -H -o name | grep '^nas'); do
    CUR="${DATASET}@${SNAP_DATE}"

    PREV=$(sudo zfs list -t snapshot -o name -s creation \
        | grep "^${DATASET}@" \
        | grep -v "${CUR}" \
        | tail -n 1)

    echo "Examining $CUR and $PREV"  # This is fine for debugging

    if [ -z "$PREV" ]; then
        DATASET_CHANGES+=("{\"dataset\":\"${DATASET}\",\"bytes\":\"NEW DATASET\"}")
        continue
    fi

    DIFF_BYTES=$(sudo zfs send -nvP "$PREV" "$CUR" 2>/dev/null | awk '/size/ {print $2}')

    if [ -n "$DIFF_BYTES" ]; then
        TOTAL_DIFF=$((TOTAL_DIFF + DIFF_BYTES))
        DATASET_CHANGES+=("{\"dataset\":\"${DATASET}\",\"bytes\":${DIFF_BYTES}}")
        echo "Delta for $DATASET: $DIFF_BYTES bytes"
    fi
done

# Summarize total change
HUMAN_TOTAL=$(numfmt --to=iec --suffix=B "$TOTAL_DIFF")
echo "Total difference is $HUMAN_TOTAL"

# Build plain text message
DETAILS_MSG="Host: $HOSTNAME Snapshot: $SNAP_NAME of $HUMAN_TOTAL"

# Send to webhook
sudo /usr/local/bin/nas_event_report.sh \
    "snapshot_stats" \
    "$DETAILS_MSG"



# Build JSON for webhook
#CHANGES_JSON=$(IFS=,; echo "${DATASET_CHANGES[*]}")
#DETAILS_JSON=$(printf "snapshot":"%s"," total":"%s" "$SNAP_NAME" "$HUMAN_TOTAL")

# Send to webhook
#sudo /usr/local/bin/nas_event_report.sh \
#    "snapshot_stats" \
#    "$DETAILS_JSON"
