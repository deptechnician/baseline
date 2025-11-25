#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

# Prompt for username and password
echo "Enter the username for the NAS monitor webhook:"
read -r NAS_MONITOR_USERNAME

echo "Enter the password for the NAS monitor webhook:"
read -rs NAS_MONITOR_PASSWORD  # The -s flag ensures the password is hidden while typing

# Create the configuration directory if it doesn't exist
CONFIG_DIR="/root/.nas_monitor"
mkdir -p "$CONFIG_DIR"

# Define the configuration file path
CONFIG_FILE="$CONFIG_DIR/creds.env"

# Write the username and password to the configuration file
cat <<EOF > "$CONFIG_FILE"
NAS_MONITOR_USERNAME="$NAS_MONITOR_USERNAME"
NAS_MONITOR_PASSWORD="$NAS_MONITOR_PASSWORD"
EOF

# Set restrictive permissions on the configuration file
chmod 600 "$CONFIG_FILE"

# Ensure the directory has the correct permissions (root only)
chmod 700 "$CONFIG_DIR"

# Output a success message
echo "Configuration file created at $CONFIG_FILE"
echo "Permissions set to 600 for the config file and 700 for the directory."

# End of script
