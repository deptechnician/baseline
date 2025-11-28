#!/bin/bash
# File: /usr/local/bin/nas_report_wake.sh
# Purpose: This script calls the nas_report_event.sh script to report the wake-up event

EVENT_SCRIPT="/usr/local/bin/nas_report_event.sh"

# Check if the event script exists and is executable
if [[ -x "$EVENT_SCRIPT" ]]; then
    # Call the event script with parameters
    "$EVENT_SCRIPT" nas_boot "System woke up from sleep or reboot"
else
    echo "$(date): ERROR - Event script not found or not executable." >> /var/log/nas_report_wake.log
    exit 1
fi
