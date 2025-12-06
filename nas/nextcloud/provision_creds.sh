#!/bin/bash

# ==========================================================
# This script will be called by setup_nextcloud.sh in order
#  to create credentials for the nextcloud instance
# ==========================================================

ENV_FILE="./.env"

# Check if the file already exists (prevent accidental overwrite)
if [ -f "$ENV_FILE" ]; then
    echo "Environment file $ENV_FILE already exists."
    echo "Changes skipped to protect existing credentials."
    exit 0
fi

echo "Generating secure credentials for Nextcloud..."

# Generate 32-character base64-encoded random strings for passwords
DB_ROOT_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
DB_NC_PASS=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)

# Prompt for Nextcloud subdomain
read -p "Enter your dedicated Nextcloud subdomain (e.g. cloud.example.com): " NEXTCLOUD_DOMAIN
if [ -z "$NEXTCLOUD_DOMAIN" ]; then
    echo "Error: Domain cannot be empty."
    exit 1
fi

# Write variables to .env
cat << EOF > "$ENV_FILE"
# Nextcloud Database Credentials - Generated $(date)
MYSQL_ROOT_PASSWORD=$DB_ROOT_PASS
MYSQL_PASSWORD=$DB_NC_PASS
MYSQL_DATABASE=nextcloud
MYSQL_USER=nextcloud

# Nextcloud domain for LAN access
NEXTCLOUD_DOMAIN=$NEXTCLOUD_DOMAIN
EOF

chmod 600 "$ENV_FILE"
echo "Credentials saved securely to $ENV_FILE"
echo "Provisioning complete."
