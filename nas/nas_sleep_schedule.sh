#!/bin/bash
# File: /usr/local/bin/nas_sleep_schedule.sh
# Purpose: Schedule daily sleep at 10 PM and wake every Sunday at 1 AM Mountain Time (MT)
#          Optionally report events via nas_report_event.sh if installed

RTCWAKE="/usr/sbin/rtcwake"
EVENT_SCRIPT="/usr/local/bin/nas_report_event.sh"

# 1. Set Mountain Time (MT) timezone for calculation
# This ensures that "next Sun 01:00" is correctly interpreted as Denver local time.
export TZ="America/Denver"

# 2. Calculate the UTC epoch timestamp for next Sunday at 1:00 AM MT.
# The '+%s' format always outputs seconds since the UTC epoch, making this the final time needed for rtcwake.
WAKE_TIME_UTC=$(date -d 'next Sun 01:00' +%s)

# 3. Get the human-readable string in MT for logging (optional)
WAKE_HUMAN=$(date -d "@$WAKE_TIME_UTC" +"%Y-%m-%d %H:%M:%S %Z")

# 4. Report the timer being set if the event script exists
if [[ -x "$EVENT_SCRIPT" ]]; then
    "$EVENT_SCRIPT" nas_sleep "Sleeping now... Wake up scheduled for $WAKE_HUMAN (UTC Epoch: $WAKE_TIME_UTC)"
fi

# 5. Put system to sleep and set the RTC wake-up time.
# The -t option expects the UTC epoch timestamp, which WAKE_TIME_UTC provides.
$RTCWAKE -m mem -t "$WAKE_TIME_UTC"