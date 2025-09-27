#!/bin/bash

CONFIG_FILE="$HOME/.dep/devices.conf"

# -------------------------------------
# Wakes a device
#--------------------------------------
function wakedevice() {
    local device_name="$1"

    # Ensure config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Config file not found at $CONFIG_FILE"
        return 1
    fi

    # Read MAC address from config
    local mac_address=$(grep -E "^${device_name}=" "$CONFIG_FILE" | cut -d'=' -f2)

    # Check for device name argument
    if [ -z "$1" ]; then
        echo "Usage: wakedevice <device_name>"
        echo " "
        echo "Available device names: "
        grep -v '^#' "$CONFIG_FILE" | cut -d'=' -f1 | xargs -n 1 echo
        return 1
    fi

    if [ -z "$mac_address" ]; then
        echo "Error: Device '$device_name' not found in config."
        echo -n "Available devices: "
        grep -v '^#' "$CONFIG_FILE" | cut -d'=' -f1 | xargs echo
        return 1
    fi

    # Send magic packet
    if command -v dnf >/dev/null 2>&1; then
        sudo ether-wake "$mac_address"
    else
        wakeonlan "$mac_address"
    fi

    echo "Issued wake command for '$device_name' ($mac_address)."
}

# Run the function with passed arguments
wakedevice "$@"
