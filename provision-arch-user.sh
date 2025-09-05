#!/bin/bash
set -euo pipefail

# Prompt for the new username
read -rp "Enter the new sudo username: " NEW_USER

# Ensure sudo is installed
if ! command -v sudo >/dev/null 2>&1; then
  echo "Installing sudo..."
  pacman -Sy --noconfirm sudo
fi

# Create the user if it doesn't already exist
if id -u "$NEW_USER" >/dev/null 2>&1; then
  echo "User '$NEW_USER' already exists."
else
  echo "Creating user '$NEW_USER'..."
  useradd -m -G wheel -s /bin/bash "$NEW_USER"
fi

# Set the user's password
echo "Set password for '$NEW_USER':"
passwd "$NEW_USER"

# Ensure the wheel group has sudo privileges
if ! grep -Eq '^[^#]*%wheel.*ALL=\(ALL(:ALL)?\) ALL' /etc/sudoers; then
  echo "Enabling sudo for wheel group..."
  echo '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/10-wheel
  chmod 0440 /etc/sudoers.d/10-wheel
fi

echo "Switching to user '$NEW_USER'..."
exec su - "$NEW_USER"

echo
echo "User '$NEW_USER' created and added to the wheel group."
echo "They can now use sudo."
