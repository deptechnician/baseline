#!/bin/bash

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Check if both event and details are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <event> <details>"
    exit 1
fi

# Read event and details
EVENT=$1
DETAILS=$2
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
DEVICE_NAME=$(hostname)
NAS_MONITOR_URL="https://trics.app.n8n.cloud/webhook/5186df0f-dec3-43dd-8946-71f13670c5b9"

# Load credentials if config exists, otherwise fail
CREDS_FILE="/root/.nas_monitor/creds.env"

if [ ! -f "$CREDS_FILE" ]; then
    echo "Credentials file not found: $CREDS_FILE"
    echo "Please run nas_monitor_setup.sh before using this script."
    exit 1
fi

# Source credentials
source "$CREDS_FILE"

# Define webhook URL from creds file
WEBHOOK_URL="$NAS_MONITOR_URL"

# Replace newlines with spaces in the DETAILS
DETAILS=$(echo "$DETAILS" | tr '\n' ' ')

# Build JSON payload safely (escapes quotes)
PAYLOAD=$(printf '{"event": "%s", "details": "%s", "timestamp": "%s", "device_name": "%s", "status": "success"}' \
  "$(printf '%s' "$EVENT" | sed 's/"/\\"/g')" \
  "$(printf '%s' "$DETAILS" | sed 's/"/\\"/g')" \
  "$TIMESTAMP" \
  "$DEVICE_NAME")

echo "Payload being sent:"
echo "$PAYLOAD"

# Send POST request with Basic Auth
RESPONSE=$(curl -X POST "$WEBHOOK_URL" \
     -u "$NAS_MONITOR_USERNAME:$NAS_MONITOR_PASSWORD" \
     -H "Content-Type: application/json" \
     --fail --silent --show-error \
     -d "$PAYLOAD")

echo "Server Response: $RESPONSE"

# Check exit code from curl
if [ $? -eq 0 ]; then
    echo "Report sent for event '$EVENT' at $TIMESTAMP"
else
    echo "Failed to send report for '$EVENT' at $TIMESTAMP"
fi

