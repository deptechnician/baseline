#!/bin/bash

set -e

echo "Bringing Tailscale interface down..."
sudo tailscale down || true

echo "Stopping Tailscale daemon..."
sudo systemctl stop tailscaled

echo "Tailscale is now disconnected."
