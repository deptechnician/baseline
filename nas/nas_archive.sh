#!/bin/bash

LOG_FILE="/var/log/nas_backup.log"

{

# --- Optional Tailscale on-demand connection ---
#
TSUP="/usr/local/bin/tsup"
TSDOWN="/usr/local/bin/tsdown"

TS_ACTIVE=0

# If tsup exists and is executable, call it
if [[ -x "$TSUP" ]]; then
    echo "tsup detected — connecting to Tailscale..."
    "$TSUP"
    TS_ACTIVE=1
else
    echo "tsup not found. Skipping Tailscale startup."
fi

# Ensure tsdown runs on exit if tsup was used
cleanup_tailscale() {
    if [[ $TS_ACTIVE -eq 1 && -x "$TSDOWN" ]]; then
        echo "Running tsdown — disconnecting from Tailscale..."
        "$TSDOWN"
    fi
}
trap cleanup_tailscale EXIT

# Check if TARGET_HOST is provided as a command line argument
if [ -z "$1" ]; then
    echo "Usage: $0 user@target_host [path_to_ssh_key]"
    exit 1
fi

# Define the source ZFS pool and dataset
SOURCE_POOL="nas"

# Take TARGET_HOST as the first argument
TARGET_HOST="$1"
TARGET_POOL="nas"

# Take the SSH key file path as the second argument (optional)
SSH_KEY_PATH="${2:-/root/.ssh/zfs_sync}"    # Default to /root/.ssh/zfs_sync if no key is provided

# If we don't have the SSH key needed for archival, fail out
if [[ ! -f "$SSH_KEY_PATH" ]]; then
    echo "ERROR: SSH key not found at $SSH_KEY_PATH"
    exit 1
fi

# Ensure SSH agent is running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    echo "Starting SSH agent..."
    eval $(ssh-agent -s)
fi

# Ensure SSH key is loaded
if ! ssh-add -l | grep -q "$SSH_KEY_PATH"; then
    echo "Loading SSH key from $SSH_KEY_PATH into agent..."
    ssh-add "$SSH_KEY_PATH"
fi

# Get latest local snapshot
SOURCE_LAST_SNAPSHOT=$(sudo zfs list "$SOURCE_POOL" -t snapshot -o name -s creation | tail -n 1)

# Get latest snapshot on receiver
RECEIVER_LAST_SNAPSHOT=$(ssh "$TARGET_HOST" "zfs list '$TARGET_POOL' -t snapshot -o name -s creation | tail -n 1")

echo
echo -------------------------------------------------------------------------------------
echo "Archiving $SOURCE_LAST_SNAPSHOT on $HOSTNAME to $RECEIVER_LAST_SNAPSHOT on $TARGET_HOST"
echo -------------------------------------------------------------------------------------
echo

# Perform full or incremental send
if [[ -z "$RECEIVER_LAST_SNAPSHOT" ]]; then
    echo "No snapshots found on the receiver. Sending full snapshot."
    sudo zfs send -w -R "$SOURCE_LAST_SNAPSHOT" | ssh "$TARGET_HOST" "sudo zfs receive -F $TARGET_POOL"
else
    echo "Sending incremental backup from $RECEIVER_LAST_SNAPSHOT to $SOURCE_LAST_SNAPSHOT."
    sudo zfs send -w -R -I "$RECEIVER_LAST_SNAPSHOT" "$SOURCE_LAST_SNAPSHOT" | ssh "$TARGET_HOST" "sudo zfs receive -F $TARGET_POOL"
fi

} >> "$LOG_FILE" 2>&1
