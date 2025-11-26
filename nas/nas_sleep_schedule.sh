#!/bin/bash
# File: /usr/local/bin/nas_sleep_schedule.sh
# Purpose: Schedule daily sleep at 10 PM and wake every Sunday at 1 AM

# Absolute paths for safety
RTCWAKE="/usr/sbin/rtcwake"

# 1. Set RTC wake for next Sunday 1:00 AM
$RTCWAKE -m no -t $(date -d 'next Sun 01:00' +%s)

# 2. Suspend system to RAM immediately
$RTCWAKE -m mem
