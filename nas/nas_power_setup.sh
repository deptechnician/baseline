#!/bin/bash

# Define the cron jobs
SLEEP_CRON="59 23 * * * /usr/sbin/rtcwake -m mem -s 0"  # Put the system to sleep every night
WAKE_CRON="0 5 * * 0 /usr/sbin/rtcwake -m no -s 0 && sleep 30"  # Wake the system up every Sunday at 5 AM with a delay

# Function to add a cron job if it doesn't already exist
add_cron_job() {
    local cron_job="$1"
    # Get current cron jobs
    CURRENT_CRON=$(sudo crontab -l 2>/dev/null)

    # Check if the cron job already exists to avoid duplicates
    if ! echo "$CURRENT_CRON" | grep -F "$cron_job" > /dev/null; then
        echo "Adding cron job: $cron_job"
        (echo "$CURRENT_CRON"; echo "$cron_job") | sudo crontab -
    else
        echo "Cron job already exists: $cron_job"
    fi
}

# Add the sleep cron job
add_cron_job "$SLEEP_CRON"

# Add the wake cron job
add_cron_job "$WAKE_CRON"

# Print the current cron jobs for verification
echo
echo "Current cron jobs:"
sudo crontab -l

