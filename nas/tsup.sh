#!/bin/bash

set -e

echo "Starting Tailscale daemon..."
sudo systemctl start tailscaled

echo "Bringing Tailscale interface up..."
sudo tailscale up

echo "Tailscale is now connected."
