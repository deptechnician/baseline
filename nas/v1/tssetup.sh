#!/bin/bash
set -e

echo "Installing tsup and tsdown..."

# Copy scripts
sudo cp tsup.sh /usr/local/bin/tsup
sudo cp tsdown.sh /usr/local/bin/tsdown

# Set execute permissions
sudo chmod +x /usr/local/bin/tsup
sudo chmod +x /usr/local/bin/tsdown

# Configure tailscale to not reconnect after reboot
sudo systemctl disable --now tailscaled || true
sudo systemctl disable tailscale 2>/dev/null || true

echo "Done."
echo "You can now run:"
echo "  tsup   - to connect to Tailscale on demand"
echo "  tsdown - to disconnect from Tailscale"
