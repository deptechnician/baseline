#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

TARGET_BIN="/usr/local/bin"

# List of scripts to install
SCRIPTS_TO_COPY=(
  "nas_report_event.sh"
  "nas_report_boot.sh"
  "nas_report.sh"
)

# Check if scripts exist before copying
echo "Checking scripts..."
for script in "${SCRIPTS_TO_COPY[@]}"; do
    if [[ ! -f "$script" ]]; then
        echo "❌ ERROR: '$script' does not exist in the current directory!"
        echo "Aborting."
        exit 1
    fi
done

# Copy scripts
echo "Copying scripts to $TARGET_BIN..."
for script in "${SCRIPTS_TO_COPY[@]}"; do
    cp "$script" "$TARGET_BIN/"
done

# Set correct permissions
echo "Setting permissions..."
for script in "${SCRIPTS_TO_COPY[@]}"; do
    chown root:root "$TARGET_BIN/$script"
    chmod 750 "$TARGET_BIN/$script"
done

# Create config directory
CREDS_DIR="/root/.nas_monitor"
mkdir -p "$CREDS_DIR"

CREDS_FILE="$CREDS_DIR/creds.env"
SHOULD_WRITE_CREDS=true # Assume we should write the file by default

# If creds already exist, ask before overwriting
if [[ -f "$CREDS_FILE" ]]; then
    echo
    echo "Credentials already exist: $CREDS_FILE"
    read -p "Do you want to overwrite them (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "Keeping existing credentials. Skipping write."
        # Set flag to false so we skip the write block
        SHOULD_WRITE_CREDS=false
    fi
fi

# --- File Writing Section ---
if $SHOULD_WRITE_CREDS ; then
    # If the file doesn't exist or user wants to overwrite, prompt for username & password
    echo "Enter the username for the NAS monitor service:"
    read -r NAS_MONITOR_USERNAME

    echo "Enter the password for the NAS monitor service:"
    read -rs NAS_MONITOR_PASSWORD # -s hides input while typing

    # Write credentials to the file (whether it's new or being overwritten)
    {
        printf "NAS_MONITOR_USERNAME=\"%s\"\n" "$NAS_MONITOR_USERNAME"
        printf "NAS_MONITOR_PASSWORD=\"%s\"\n" "$NAS_MONITOR_PASSWORD"
    } > "$CREDS_FILE"

    # Set permissions for the credentials file
    chmod 600 "$CREDS_FILE"
    chmod 700 "$CREDS_DIR"

    echo "--------------------------------------------------"
    echo "Credentials file created (or overwritten) at: $CREDS_FILE"
    echo "--------------------------------------------------"
fi

echo "--------------------------------------------------"
echo "Creds file: $CREDS_FILE"
echo "Scripts installed to: $TARGET_BIN"
echo "Permissions locked down."
echo ""
echo "You can now run the script manually using:"
echo "   $TARGET_BIN/nas_report_event.sh"
echo "--------------------------------------------------"

# --- Add Cron Jobs for Weekly Reports ---
LOG_FILE="/var/log/nas_report.log"

# Function to add a cron job without duplicates
add_cron_job() {
    local cron_job="$1"
    CURRENT_CRON=$(sudo crontab -l 2>/dev/null)

    if ! echo "$CURRENT_CRON" | grep -F "$cron_job" > /dev/null; then
        (echo "$CURRENT_CRON"; echo "$cron_job") | sudo crontab -
    fi
}

# Add cron job for NAS reporting (1 PM every Sunday)
add_cron_job "0 13 * * 0 /usr/local/bin/nas_report.sh"

# Add cron job for wake-up event reporting (runs on boot)
add_cron_job "@reboot /usr/local/bin/nas_report_boot.sh"

echo "Current cron jobs:"
sudo crontab -l

