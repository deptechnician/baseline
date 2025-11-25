#!/bin/bash

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
SSH_KEY_PATH="${2:-$HOME/.ssh/id_rsa}"  # Default to ~/.ssh/id_rsa if no key is provided

# Ensure SSH key is loaded into the SSH agent
# Check if the SSH agent is running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    echo "Starting SSH agent..."
    eval $(ssh-agent -s)
fi

# Check if the key is loaded
if ! ssh-add -l | grep -q "$SSH_KEY_PATH"; then
    echo "Loading SSH key from $SSH_KEY_PATH into agent..."
    if [[ -f "$SSH_KEY_PATH" ]]; then
        ssh-add "$SSH_KEY_PATH"
    else
        echo "Error: SSH key file $SSH_KEY_PATH does not exist!"
        exit 1
    fi
fi

# Get the most recent snapshot on the source
SOURCE_LAST_SNAPSHOT=$(sudo zfs list "$SOURCE_POOL" -t snapshot -o name -s creation | tail -n 1)

# Get the most recent snapshot on the receiver (TARGET_HOST)
RECEIVER_LAST_SNAPSHOT=$(ssh "$TARGET_HOST" "zfs list '$TARGET_POOL' -t snapshot -o name -s creation | tail -n 1")

echo
echo -------------------------------------------------------------------------------------
echo "Archiving $SOURCE_LAST_SNAPSHOT on $HOSTNAME to $RECEIVER_LAST_SNAPSHOT on $TARGET_HOST"
echo -------------------------------------------------------------------------------------
echo 

# If there's no snapshot on the receiver (first backup), use the first available source snapshot
if [[ -z "$RECEIVER_LAST_SNAPSHOT" ]]; then
    echo "No snapshots found on the receiver. Sending full snapshot."
    # Send full snapshot with -w (raw encrypted data) and -R (recursive, including children)
    sudo zfs send -w -R "$SOURCE_LAST_SNAPSHOT" | ssh "$TARGET_HOST" "sudo zfs receive -F $TARGET_POOL"
else
    # Send incremental backup with -w (raw encrypted data) and -R (recursive, including children)
    echo "Sending incremental backup from $RECEIVER_LAST_SNAPSHOT to $SOURCE_LAST_SNAPSHOT."
    sudo zfs send -w -R -I "$RECEIVER_LAST_SNAPSHOT" "$SOURCE_LAST_SNAPSHOT" | ssh "$TARGET_HOST" "sudo zfs receive -F $TARGET_POOL"
fi
