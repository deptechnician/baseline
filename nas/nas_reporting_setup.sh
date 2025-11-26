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

# Prompt for username & password
echo "Enter the username for the NAS monitor webhook:"
read -r NAS_MONITOR_USERNAME

echo "Enter the password for the NAS monitor webhook:"
read -rs NAS_MONITOR_PASSWORD  # -s hides input while typing

# Create config directory
CONFIG_DIR="/root/.nas_monitor"
mkdir -p "$CONFIG_DIR"

CONFIG_FILE="$CONFIG_DIR/creds.env"

# If creds already exist, ask before overwriting
if [[ -f "$CONFIG_FILE" ]]; then
    echo
    echo "⚠️  WARNING: Config already exists at $CONFIG_FILE"
    read -p "Do you want to overwrite it? (y/N): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        echo "Keeping existing credentials. Skipping write."
        exit 0
    fi
fi

# Write credentials
cat <<EOF > "$CONFIG_FILE"
NAS_MONITOR_USERNAME="$NAS_MONITOR_USERNAME"
NAS_MONITOR_PASSWORD="$NAS_MONITOR_PASSWORD"
EOF

chmod 600 "$CONFIG_FILE"      # protect file
chmod 700 "$CONFIG_DIR"       # protect directory

echo "--------------------------------------------------"
echo "Configuration file created at: $CONFIG_FILE"
echo "Scripts installed to: $TARGET_BIN"
echo "Permissions locked down."
echo "--------------------------------------------------"
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
        echo "Adding cron job: $cron_job"
        (echo "$CURRENT_CRON"; echo "$cron_job") | sudo crontab -
    else
        echo "Cron job already exists: $cron_job"
    fi
}

# Add cron job for NAS reporting (1 PM every Sunday)
add_cron_job "0 13 * * 0 /usr/local/bin/nas_report.sh"

echo "--------------------------------------------------"
echo "Cron jobs created to run at 1PM every Sunday:"
echo "  • zfs pool report"
echo "  • zfs snapshot report"
echo "Output will be logged to: $LOG_FILE"
echo "--------------------------------------------------"

echo "Current cron jobs:"
sudo crontab -l

