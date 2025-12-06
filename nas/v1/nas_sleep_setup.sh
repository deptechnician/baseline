#!/bin/bash

# --- Define paths ---
SCRIPT_NAME="nas_sleep_schedule.sh"
SOURCE_SCRIPT="./$SCRIPT_NAME"
DEST_SCRIPT="/usr/local/bin/$SCRIPT_NAME"

# --- Check if the script exists in the current directory ---
if [ ! -f "$SOURCE_SCRIPT" ]; then
    echo "Error: $SOURCE_SCRIPT not found in the current directory."
    exit 1
fi

# --- Copy the script to /usr/local/bin ---
echo "Copying $SOURCE_SCRIPT to $DEST_SCRIPT..."
sudo cp "$SOURCE_SCRIPT" "$DEST_SCRIPT"

# --- Make the script executable ---
echo "Setting executable permissions on $DEST_SCRIPT..."
sudo chmod +x "$DEST_SCRIPT"

# --- Define the cron job ---
SLEEP_CRON="0 22 * * * $DEST_SCRIPT"

# --- Function to add a cron job if it doesn't already exist ---
add_cron_job() {
    local cron_job="$1"
    CURRENT_CRON=$(sudo crontab -l 2>/dev/null)
    if ! echo "$CURRENT_CRON" | grep -F "$cron_job" > /dev/null; then
        echo "Adding cron job: $cron_job"
        (echo "$CURRENT_CRON"; echo "$cron_job") | sudo crontab -
    else
        echo "Cron job already exists: $cron_job"
    fi
}

# --- Add the daily sleep/wake cron job ---
add_cron_job "$SLEEP_CRON"

# --- Print current cron jobs for verification ---
echo
echo "Current root cron jobs:"
sudo crontab -l


