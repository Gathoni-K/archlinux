#!/bin/bash
# Format, label, and mount existing Arch partitions
# WARNING: This will ERASE all data on the specified partitions.

DISK="/dev/nvme0n1"   # Change to your actual disk
EFI="${DISK}p5"       # EFI partition
SWAP="${DISK}p6"      # Swap partition
ROOT="${DISK}p7"      # Root partition

echo "The following partitions will be formatted and mounted:"
echo "EFI:  $EFI  -> FAT32 (Label: ARCH EFI)"
echo "SWAP: $SWAP -> Swap (Label: ARCH LINUX SWAP)"
echo "ROOT: $ROOT -> ext4 (Label: ARCH LINUX)"
echo
read -p "Type YES to confirm and proceed: " CONFIRM

if [[ "$CONFIRM" != "YES" ]]; then
  echo "Aborted by user."
  exit 1
fi

echo "Formatting partitions..."
mkfs.fat -F32 -n "ARCH EFI" "$EFI"
mkswap -L "ARCH LINUX SWAP" "$SWAP"
mkfs.ext4 -L "ARCH LINUX" "$ROOT"

echo "Mounting partitions..."
mount "$ROOT" /mnt
mkdir -p /mnt/boot
mount "$EFI" /mnt/boot
swapon "$SWAP"

echo "All done! Current partition layout:"
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT
