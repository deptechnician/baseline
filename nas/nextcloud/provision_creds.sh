#!/bin/bash

# ==========================================================
# 1. ROOT PRIVILEGE CHECK
# ==========================================================
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run with sudo or as root."
    echo "Please run: sudo ./setup_nextcloud.sh"
    exit 1
fi

# ==========================================================
# 2. Variable Definitions
# ==========================================================
ENV_FILE="/root/nextcloudcreds.env"

# ==========================================================
# 3. Security and Credential Generation
# ==========================================================
# Check if the file already exists (prevent accidental overwrite)
if [ -f "$ENV_FILE" ]; then
    echo "ERROR: Environment file $ENV_FILE already exists."
    echo "Deployment aborted to protect existing credentials."
    exit 1
fi

echo "Generating secure credentials for Nextcloud..."

# Generate 32-character base64-encoded random strings for passwords
# Using 'tr -dc' to ensure only alphanumeric and safe characters are included
DB_ROOT_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
DB_NC_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)

# Write the variables to the secure file
cat << EOF > "$ENV_FILE"
# Nextcloud Database Credentials - Generated $(date)
MYSQL_ROOT_PASSWORD=$DB_ROOT_PASS
MYSQL_PASSWORD=$DB_NC_PASS
EOF

# Set strict permissions: readable only by root
chmod 600 "$ENV_FILE"
echo "Credentials saved securely to $ENV_FILE"

echo "Credentials are provisioned."
