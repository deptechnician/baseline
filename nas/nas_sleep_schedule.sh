#!/bin/bash
# File: /usr/local/bin/nas_sleep_schedule.sh
# Purpose: Schedule daily sleep at 10 PM and wake every Sunday at 1 AM
#          Optionally report events via nas_report_event.sh if installed

RTCWAKE="/usr/sbin/rtcwake"
EVENT_SCRIPT="/usr/local/bin/nas_report_event.sh"

# 1. Calculate next Sunday 1:00 AM timestamp
WAKE_TIME=$(date -d 'next Sun 01:00' +%s)
WAKE_HUMAN=$(date -d "@$WAKE_TIME" +"%Y-%m-%d %H:%M:%S")

# 2. Report the timer being set if the event script exists
if [[ -x "$EVENT_SCRIPT" ]]; then
    "$EVENT_SCRIPT" nas_sleep "RTC wake timer set for next Sunday at $WAKE_HUMAN (epoch: $WAKE_TIME)"
fi

# 3. Set RTC wake without suspending yet
$RTCWAKE -m no -t "$WAKE_TIME"

# 4. Report that the system is going to sleep if the event script exists
if [[ -x "$EVENT_SCRIPT" ]]; then
    "$EVENT_SCRIPT" nas_sleep "System going to sleep now..."
fi

# 5. Suspend system to RAM
$RTCWAKE -m mem

