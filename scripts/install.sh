#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Error: Run as root${NC}"
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Usage: ./install.sh /mnt"
  exit 1
fi

MOUNT_POINT="$1"

if ! mountpoint -q "$MOUNT_POINT"; then
  echo -e "${RED}Error: $MOUNT_POINT is not mounted${NC}"
  exit 1
fi

echo -e "${GREEN}Installing NixOS to $MOUNT_POINT...${NC}"

# Generate hardware configuration
echo -e "${YELLOW}Generating hardware configuration...${NC}"
nixos-generate-config --root "$MOUNT_POINT"

# Copy our flake configuration to /mnt/etc/nixos/
echo -e "${YELLOW}Copying configuration files...${NC}"
CONFIG_DIR="$MOUNT_POINT/etc/nixos"

# Copy our config files
cp "$(dirname "$0")/flake.nix" "$CONFIG_DIR/"
cp "$(dirname "$0")/configuration.nix" "$CONFIG_DIR/"
cp "$(dirname "$0")/home.nix" "$CONFIG_DIR/"
cp "$(dirname "$0")/README.md" "$CONFIG_DIR/" 2>/dev/null || true
cp "$(dirname "$0")/.gitignore" "$CONFIG_DIR/" 2>/dev/null || true

# Remove backup file if it exists
rm -f "$CONFIG_DIR/configuration.nix.bak"

# Install NixOS
echo -e "${YELLOW}Installing NixOS (this may take a while)...${NC}"
nixos-install --root "$MOUNT_POINT" --flake "$CONFIG_DIR#leavenworth"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Reboot: reboot"
echo "2. Login as: svea / changeme"
echo "3. Change password: passwd"
echo "4. Config is in: /etc/nixos"
echo "5. Rebuild: sudo nixos-rebuild switch --flake /etc/nixos#leavenworth"
echo ""
