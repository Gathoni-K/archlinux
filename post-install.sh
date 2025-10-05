#!/bin/bash
# Post-install GRUB & EFI setup script with OS-prober enabled
# To be run inside arch-chroot after mounting root and EFI

set -euo pipefail

# 1. Update package database & install required packages
pacman -Syyu --noconfirm grub efibootmgr dosfstools mtools os-prober

# 2. Variables — change if your mount points differ
EFI_DIR="/boot"         # the mount point of your EFI partition inside chroot
BOOTLOADER_ID="Arch"    # what name will appear in firmware (you can change)

# 3. Enable OS-prober in GRUB config
if grep -q "^#GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
    sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
elif ! grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
    echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub
fi

# 4. Install GRUB in EFI mode
grub-install \
  --target=x86_64-efi \
  --efi-directory="${EFI_DIR}" \
  --bootloader-id="${BOOTLOADER_ID}" \
  --recheck

# 5. Generate GRUB config (update-grub equivalent)
grub-mkconfig -o /boot/grub/grub.cfg

echo "✅ GRUB installed, OS-prober enabled, and configuration updated."
