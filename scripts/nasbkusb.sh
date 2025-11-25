#!/bin/bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo " "
  echo "Usage: $0 <usb_pool_name>"
  echo " "
  zpool list
  echo " "
  exit 1
fi

SOURCE_POOL="nas"
USB_POOL="$1"
SNAP_PREFIX="snapshot"
TODAY=$(date +%Y%m%d)
SNAP_NAME="${SNAP_PREFIX}-${TODAY}"

echo "🔁 Starting backup from ${SOURCE_POOL} to USB pool ${USB_POOL}"

# Import USB pool if not imported
if ! sudo zpool list -H -o name | grep -qx "${USB_POOL}"; then
  echo "🔌 Importing USB pool ${USB_POOL}..."
  sudo zpool import -N "${USB_POOL}"
fi

# Check if USB_POOL/nas dataset exists, create if missing
if ! sudo zfs list -H -o name "${USB_POOL}/${SOURCE_POOL}" &>/dev/null; then
  echo "➕ Creating dataset ${USB_POOL}/${SOURCE_POOL} on USB pool..."
  sudo zfs create "${USB_POOL}/${SOURCE_POOL}"
fi

# Check if snapshot exists
if sudo zfs list -t snapshot -r -o name | grep -q "^${SOURCE_POOL}@${SNAP_NAME}$"; then
  echo "⚠️ Snapshot ${SOURCE_POOL}@${SNAP_NAME} already exists, skipping snapshot creation."
else
  echo "📸 Creating recursive snapshot ${SOURCE_POOL}@${SNAP_NAME}..."
  sudo zfs snapshot -r "${SOURCE_POOL}@${SNAP_NAME}"
fi

# Find latest snapshot on USB pool for incremental send
last_usb_snap=$(sudo zfs list -H -t snapshot -o name -S creation -r "${USB_POOL}/${SOURCE_POOL}" | grep "@${SNAP_PREFIX}-" | head -n1 || true)

if [[ -z "$last_usb_snap" ]]; then
  echo "📦 No previous snapshot on USB pool, sending full recursive snapshot with raw encryption..."
  sudo zfs send -w -R "${SOURCE_POOL}@${SNAP_NAME}" | sudo zfs receive -Fdu "${USB_POOL}/${SOURCE_POOL}"
else
  echo "🔁 Found previous snapshot ${last_usb_snap}, sending incremental with raw encryption..."
  sudo zfs send -w -R -I "${last_usb_snap}" "${SOURCE_POOL}@${SNAP_NAME}" | sudo zfs receive -Fdu "${USB_POOL}/${SOURCE_POOL}"
fi

echo "💾 Exporting USB pool ${USB_POOL}..."
sudo zpool export "${USB_POOL}"

echo "✅ Backup complete!"
