#!/bin/bash

set -e

echo "=============================================="
echo "   Nextcloud + Caddy + MariaDB Setup    "
echo "=============================================="

# --- 1. Call external provisioning script ---
echo "Calling provision_creds.sh to create .env..."
if ! ./provision_creds.sh; then
    echo "Error: provision_creds.sh failed."
    exit 1
fi
echo "Credentail provisioing complete (.env file)."

# --- 2. Load environment variables ---
source .env

if [ -z "$NEXTCLOUD_DOMAIN" ]; then
    echo "Error: NEXTCLOUD_DOMAIN not set in .env"
    exit 1
fi

# --- 3. Generate Caddyfile ---
echo "Generating Caddyfile..."

cat <<EOF > Caddyfile
$NEXTCLOUD_DOMAIN {
    encode gzip

    # LAN-only self-signed TLS
    tls internal

    reverse_proxy app:80

    redir /.well-known/carddav /remote.php/dav 301
    redir /.well-known/caldav /remote.php/dav 301

    header Strict-Transport-Security "max-age=31536000; includeSubDomains"
}
EOF

# --- 4. Generate docker-compose.yml ---
echo "Generating docker-compose.yml..."

cat <<EOF > docker-compose.yml
services:
  db:
    image: mariadb:10.5
    restart: always
    command: --transaction-isolation=READ-COMMITTED --binlog-format=ROW
    volumes:
      - db_data:/var/lib/mysql
    env_file:
      - .env

  app:
    image: nextcloud:latest
    restart: always
    env_file:
      - .env
    volumes:
      - nc_data:/var/www/html/data
      - nc_config:/var/www/html/config
      - nc_apps:/var/www/html/apps
    environment:
      - MYSQL_HOST=db
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - NEXTCLOUD_TRUSTED_DOMAINS=\${NEXTCLOUD_DOMAIN}
      - OVERWRITEHOST=\${NEXTCLOUD_DOMAIN}
      - OVERWRITEPROTOCOL=https
      - OVERWRITECLIURL=https://\${NEXTCLOUD_DOMAIN}
      - TRUSTED_PROXIES=172.16.0.0/12 192.168.0.0/16 10.0.0.0/8
      - PHP_MEMORY_LIMIT=512M
      - PHP_UPLOAD_LIMIT=512M

  caddy:
    image: caddy:latest
    restart: always
    ports:
      - "80:80"
      - "443:443"
    env_file:
      - .env
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config

volumes:
  db_data:
  nc_data:
  nc_config:
  nc_apps:
  caddy_data:
  caddy_config:
EOF

echo ""
echo "=============================================="
echo "Configuration generated successfully!"
echo "Files created: .env, Caddyfile, docker-compose.yml"
echo "NEXT STEP: Run: docker-compose up -d"
echo "Your Nextcloud will be available at https://$NEXTCLOUD_DOMAIN (self-signed internal cert)."
echo "=============================================="
echo ""