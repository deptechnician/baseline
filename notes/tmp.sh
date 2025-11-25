#!/usr/bin/env bash
# Setup LUKS auto-unlock using TPM2 on Ubuntu 25.10
# Usage:
#   sudo ./setup-tpm-luks.sh /dev/nvme0n1p3
#
# Replace /dev/nvme0n1p3 with your actual LUKS device.

set -e

# --- INPUT VALIDATION ---
if [ -z "$1" ]; then
    echo "Usage: sudo $0 /dev/<LUKS_DEVICE>"
    exit 1
fi

DEVICE="$1"
HEADER_BACKUP="luks-header-backup-$(date +%Y%m%d-%H%M%S).img"

echo "====================================================="
echo "   LUKS + TPM2 AUTO-UNLOCK SETUP"
echo "   Target Device: $DEVICE"
echo "====================================================="

# --- CHECK ROOT ---
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (sudo)."
    exit 1
fi

# --- INSTALL REQUIRED PACKAGES ---
echo "📦 Installing Clevis + TPM tools..."
apt update
apt install -y clevis clevis-tpm2 clevis-luks tpm2-tools

# --- VERIFY TPM ---
echo "🔍 Testing TPM..."
if tpm2_getrandom 8 >/dev/null 2>&1; then
    echo "✔ TPM seems healthy."
else
    echo "❌ TPM test failed! Check BIOS & TPM settings."
    exit 1
fi

# --- BACKUP LUKS HEADER ---
echo "💾 Backing up LUKS header to $HEADER_BACKUP ..."
cryptsetup luksHeaderBackup "$DEVICE" --header-backup-file "$HEADER_BACKUP"
echo "✔ Backup created: $HEADER_BACKUP"
echo "   (STORE THIS SAFELY — USB or external disk!)"

# --- BIND TPM2 TO LUKS ---
echo "🔐 Binding TPM2 to LUKS slot..."
echo "You may be prompted for your existing LUKS passphrase."
clevis luks bind -d "$DEVICE" tpm2 '{}' || {
    echo "❌ TPM binding failed!"
    exit 1
}

# --- SHOW LUKS SLOTS ---
echo "🔎 Verifying that TPM binding was added..."
cryptsetup luksDump "$DEVICE"

# --- EXTRACT UUID ---
UUID=$(blkid -s UUID -o value "$DEVICE")
if [ -z "$UUID" ]; then
    echo "❌ Failed to get UUID for $DEVICE"
    exit 1
fi

# --- UPDATE CRYPTTAB ---
echo "📝 Updating /etc/crypttab ..."
CRYPTTAB_LINE="cryptroot UUID=$UUID none luks,discard,initramfs"
if grep -q "^cryptroot" /etc/crypttab; then
    sed -i "s|^cryptroot.*|$CRYPTTAB_LINE|" /etc/crypttab
else
    echo "$CRYPTTAB_LINE" >> /etc/crypttab
fi

# --- UPDATE INITRAMFS ---
echo "🔧 Updating initramfs ..."
update-initramfs -u -k all

# --- TEST UNLOCK VIA TPM (no reboot needed) ---
echo "🧪 Testing TPM unlock without reboot..."
if clevis luks unlock -d "$DEVICE" >/dev/null 2>&1; then
    echo "🎉 SUCCESS! TPM unlock works!"
else
    echo "⚠ WARNING: TPM unlock FAILED!"
    echo "    Try using:    journalctl -b | grep clevis"
fi

echo "====================================================="
echo "   FINISHED! Reboot to test auto-unlock."
echo "   Backup LUKS header: $HEADER_BACKUP"
echo "====================================================="
echo "👉 If boot fails, you can still unlock manually!"
echo "👉 Use: journalctl -b | grep clevis   to debug."
