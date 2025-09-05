#!/bin/bash

# MAKE SURE TO RUN provision-arch-user.sh FIRST
#

# Stop on any error
set -e

echo "=============================="
echo "🔄 Updating system..."
echo "=============================="
sudo pacman -Syu --noconfirm

echo "=============================="
echo "🖥️ Installing KDE Plasma Desktop..."
echo "=============================="
sudo pacman -S --noconfirm plasma kde-applications sddm konsole dolphin

echo "=============================="
echo "🔒 Installing security tools..."
echo "=============================="
sudo pacman -S --noconfirm ufw apparmor apparmor-utils audit polkit sudo

echo "=============================="
echo "🔧 Enabling AppArmor..."
echo "=============================="
sudo systemctl enable apparmor.service
sudo systemctl start apparmor.service

echo "=============================="
echo "🛡️ Enabling the UFW Firewall..."
echo "=============================="
sudo systemctl enable ufw.service
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

echo "=============================="
echo "📦 Installing Flatpak and Brave Browser..."
echo "=============================="
sudo pacman -S --noconfirm flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.brave.Browser

echo "=============================="
echo "🔄 Setting up automatic system updates..."
echo "=============================="
# Create systemd service
sudo bash -c 'cat > /etc/systemd/system/pacman-update.service <<EOF
[Unit]
Description=Auto Update System with pacman
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Syu --noconfirm
EOF'

# Create systemd timer
sudo bash -c 'cat > /etc/systemd/system/pacman-update.timer <<EOF
[Unit]
Description=Weekly System Update

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
EOF'

# Enable the timer
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now pacman-update.timer

echo "=============================="
echo "🔐 Enabling SDDM Display Manager..."
echo "=============================="
sudo systemctl enable sddm.service

echo "=============================="
echo "✅ All done! Your secure KDE system is ready."
echo "💡 Reboot your system to start using KDE Plasma."
echo "=============================="
