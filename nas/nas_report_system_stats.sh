#!/bin/bash
# File: /usr/local/bin/nas_report_system_stats.sh
# Purpose: Report uptime, temperature, last reboot, CPU average usage, load average, and memory usage.

EVENT_SCRIPT="/usr/local/bin/nas_report_event.sh"

# 1. Get Useful System Information
HOSTNAME=$(hostname)
UPTIME=$(uptime -p)  # Human-readable uptime (e.g., "up 1 hour, 20 minutes")
LAST_REBOOT=$(who -b | awk '{print $3, $4}')  # Last system reboot time
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')  # CPU usage percentage
LOAD_AVERAGE=$(uptime | awk -F'load average: ' '{ print $2 }')  # System load averages
MEM_USAGE=$(free -h | awk '/Mem:/ {print $3 "/" $2}')  # Memory usage (used/total)

# 2. Check CPU temperature (if available)
if command -v sensors &> /dev/null; then
    CPU_TEMP=$(sensors | grep 'Core 0' | awk '{print $3}')  # CPU temperature (requires `sensors` command)
else
    CPU_TEMP="N/A"  # If `sensors` is not available, set as N/A
fi

# 3. Check Disk temperature (if available)
if command -v smartctl &> /dev/null; then
    DISK_TEMP=$(smartctl -A /dev/sda | grep Temperature_Celsius | awk '{print $10}')  # Disk temperature (requires `smartctl` command)
else
    DISK_TEMP="N/A"  # If `smartctl` is not available, set as N/A
fi

# 4. Format the Report
REPORT_MESSAGE="$HOSTNAME: Uptime: $UPTIME, CPU Temp: $CPU_TEMP, CPU Usage: $CPU_USAGE%, Last Reboot: $LAST_REBOOT, Load Av:  $LOAD_AVERAGE, Memory Usage: $MEM_USAGE"

# 5. Report the event if the event script exists and is executable
if [[ -x "$EVENT_SCRIPT" ]]; then
    # Call the event script with the system stats report
    "$EVENT_SCRIPT" nas_system_stats "$REPORT_MESSAGE"
else
    # Log error to a file if event script is not found or not executable
    echo "$(date): ERROR - Event script not found or not executable. $REPORT_MESSAGE" >> /var/log/nas_report_system_stats.log
    exit 1
fi
