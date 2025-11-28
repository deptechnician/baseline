#!/bin/bash
# File: /usr/local/bin/nas_sleep_schedule.sh
# Purpose: Schedule daily sleep at 10 PM and wake every Sunday at 1 AM Mountain Time (MT)
#          Optionally report events via nas_report_event.sh if installed

RTCWAKE="/usr/sbin/rtcwake"
EVENT_SCRIPT="/usr/local/bin/nas_report_event.sh"

# 1. Set Mountain Time (MT) timezone for calculation
export TZ="America/Denver"  # This ensures we calculate the wake time in MT

# 2. Calculate next Sunday 1:00 AM Mountain Time timestamp
WAKE_TIME=$(date -d 'next Sun 01:00' +%s)  # Get the timestamp for next Sunday at 1:00 AM in MT
WAKE_HUMAN=$(date -d "@$WAKE_TIME" +"%Y-%m-%d %H:%M:%S")  # Convert to human-readable format in MT

# 3. Convert that timestamp to UTC for rtcwake
WAKE_TIME_UTC=$(date -u -d "@$WAKE_TIME" +%s)  # Convert the MT time to UTC epoch time

# 4. Report the timer being set if the event script exists
if [[ -x "$EVENT_SCRIPT" ]]; then
    "$EVENT_SCRIPT" nas_sleep_timer "Wake timer set: Sunday at $WAKE_HUMAN (epoch: $WAKE_TIME_UTC)"
fi

# 5. Put system to sleep and set the RTC wake-up time for next Sunday at 1 AM Mountain Time (converted to UTC)
$RTCWAKE -m mem -t "$WAKE_TIME_UTC"  # Set the wake time in UTC

# 6. Report that the system is going to sleep if the event script exists
if [[ -x "$EVENT_SCRIPT" ]]; then
    "$EVENT_SCRIPT" nas_sleep "System going to sleep now..."
fi

