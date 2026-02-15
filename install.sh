#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
  echo "Error: Run as root"
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Usage: ./install.sh /mnt"
  exit 1
fi

MOUNT_POINT="$1"

if ! mountpoint -q "$MOUNT_POINT"; then
  echo "Error: $MOUNT_POINT is not mounted"
  exit 1
fi

echo "Installing NixOS to $MOUNT_POINT..."

# Generate hardware config
nixos-generate-config --root "$MOUNT_POINT"

# Copy configuration
mkdir -p "$MOUNT_POINT/etc/nixos"
cp -r "$(dirname "$0")"/* "$MOUNT_POINT/etc/nixos/"

# Move generated hardware config to replace template
mv "$MOUNT_POINT/etc/nixos/hardware-configuration.nix" "$MOUNT_POINT/etc/nixos/hardware-configuration.nix.bak"
mv "$MOUNT_POINT/etc/nixos/nixos-config/hardware-configuration.nix" "$MOUNT_POINT/etc/nixos/" 2>/dev/null || true
rm -f "$MOUNT_POINT/etc/nixos/configuration.nix"

# Install
nixos-install --root "$MOUNT_POINT" --flake "$MOUNT_POINT/etc/nixos#leavenworth"

echo ""
echo "Installation complete!"
echo "Config location: /etc/nixos"
echo "User: svea (password: changeme)"
echo "Rebuild: sudo nixos-rebuild switch --flake /etc/nixos#leavenworth"
