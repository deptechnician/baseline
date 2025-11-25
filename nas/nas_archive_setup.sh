#!/bin/bash

echo
echo "This script will prepare a NAS server to archive its datasets to another host, onsite or offsite each week."
echo "In order to run, it needs the following in the current directory:"
echo "   nas_archive.sh"
echo "   nas_snapshot.sh"
echo
echo "Additionaly, the following ssh key should be in your .ssh folder"
echo "   zfs_sync"
echo
echo "The script will copy these files to the appropriate places, set their permissions, and set up the"
echo "cron jobs."
echo 
echo "It is recommended to copy this script along with all the necessary files into a temporary directory and run"
echo "this command from there."
echo

# Ensure we are in the correct directory (optional, but can be useful for clarity)
echo "Current directory: $(pwd)"
echo 

# Define the source files (in the current directory)
SCRIPT_1="nas_snapshot.sh"
SCRIPT_2="nas_archive.sh"
SSH_KEY="zfs_sync"
LOG_FILE="nas_backup.log"

# Define the target directories
TARGET_BIN="/usr/local/bin"
TARGET_LOG="/var/log"
TARGET_SSH="/root/.ssh"  # Ensure root has access to the key

# Copy the ssh keys
echo "Copying SSH key for root access during the cron job"
if [[ -f "$HOME/.ssh/$SSH_KEY" ]]; then
    sudo cp "$HOME/.ssh/$SSH_KEY" "$TARGET_SSH/"
else
    echo "Error: The file $SSH_KEY is not present in $HOME/.ssh"
    echo
    exit 1
fi

# Copy scripts to /usr/local/bin
echo "Copying scripts to $TARGET_BIN..."

# Check if the scripts exist before copying
if [[ -f "$SCRIPT_1" && -f "$SCRIPT_2" ]]; then
    sudo cp "$SCRIPT_1" "$TARGET_BIN/"
    sudo cp "$SCRIPT_2" "$TARGET_BIN/"
else
    echo "Error: One or more of the scripts do not exist in the current directory!"
    echo
    exit 1
fi

# Copy log file to /var/log if it exists
if [[ -f "$LOG_FILE" ]]; then
    sudo cp "$LOG_FILE" "$TARGET_LOG/"
else
    # If the log file doesn't exist, create it with touch
    echo "Log file $LOG_FILE not found. Creating empty log file..."
    sudo touch "$TARGET_LOG/$LOG_FILE"
fi

# Set correct permissions for the ssh key file
echo "Setting permissions for SSH key in $TARGET_SSH/$SSH_KEY..."
sudo chown root:root "$TARGET_SSH/$SSH_KEY"
sudo chmod 600 "$TARGET_SSH/$SSH_KEY"

# Set correct permissions for the scripts
echo "Setting permissions for scripts in $TARGET_BIN..."
sudo chown root:root "$TARGET_BIN/$SCRIPT_1"
sudo chown root:root "$TARGET_BIN/$SCRIPT_2"
sudo chmod 750 "$TARGET_BIN/$SCRIPT_1"
sudo chmod 750 "$TARGET_BIN/$SCRIPT_2"

# Set correct permissions for the log file
echo "Setting permissions for the log file in $TARGET_LOG..."
sudo chown root:root "$TARGET_LOG/$LOG_FILE"
sudo chmod 600 "$TARGET_LOG/$LOG_FILE"

# Print success message
echo "Files copied and permissions set successfully!"

# Prompt user for target host for cron job
read -p "Please enter the target for the backup (in the form user@host): " TARGET_HOST

# Setting up cron job
echo "Setting up weekly cron job..."

# Define the cron job commands

# 1) Wake the machine and create the snapshot
CRON_SNAPSHOT_CMD="sudo rtcwake -m no -s 300 && /usr/local/bin/nas_snapshot.sh >> $TARGET_LOG/nas_backup.log 2>&1"

# 2) Archive to the remote host
CRON_ARCHIVE_CMD="/usr/local/bin/nas_archive.sh $TARGET_HOST $TARGET_SSH/$SSH_KEY >> $TARGET_LOG/nas_backup.log 2>&1"

# Function to add a cron job without overwriting existing ones
add_cron_job() {
    local cron_job="$1"
    # Get the current cron jobs
    CURRENT_CRON=$(sudo crontab -l 2>/dev/null)

    # Check if the new cron job already exists to avoid duplicates
    if ! echo "$CURRENT_CRON" | grep -F "$cron_job" > /dev/null; then
        echo "Adding cron job: $cron_job"
        # Add the new cron job, keeping the existing ones intact
        (echo "$CURRENT_CRON"; echo "$cron_job") | sudo crontab -
    else
        echo "Cron job already exists: $cron_job"
    fi
}

# Run snapshot every Sunday at 3:00 AM
add_cron_job "0 3 * * 0 $CRON_SNAPSHOT_CMD"

# Run archive every Sunday at 3:15 AM (after the snapshot finishes)
add_cron_job "15 3 * * 0 $CRON_ARCHIVE_CMD"

echo "Cron jobs set up successfully:"
echo "  - Snapshot at 3:00 AM on Sundays"
echo "  - Archive at 3:15 AM on Sundays"

# Print current cron jobs to verify the new job
echo
echo "Current cron jobs:"
echo "-------------------"
sudo crontab -l
echo
