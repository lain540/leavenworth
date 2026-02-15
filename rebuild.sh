#!/usr/bin/env bash
# Rebuild script - pulls latest config from GitHub and rebuilds system
# Preserves hardware-configuration.nix (machine-specific)

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_DIR="/etc/nixos"
BACKUP_DIR="$CONFIG_DIR/backups"
REPO_URL="https://github.com/lain540/leavenworth.git"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CURRENT_BACKUP="$BACKUP_DIR/$TIMESTAMP"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Leavenworth System Rebuild${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Ensure we're in the config directory
if [ ! -d "$CONFIG_DIR" ]; then
  echo -e "${RED}Error: $CONFIG_DIR does not exist${NC}"
  exit 1
fi

cd "$CONFIG_DIR"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to create backup
create_backup() {
  echo -e "${YELLOW}Creating backup at $CURRENT_BACKUP...${NC}"
  mkdir -p "$CURRENT_BACKUP"
  
  # Backup all config files INCLUDING hardware-configuration.nix
  for file in *.nix *.sh *.md .gitignore flake.lock; do
    if [ -f "$file" ]; then
      cp "$file" "$CURRENT_BACKUP/" 2>/dev/null || true
    fi
  done
  
  echo -e "${GREEN}Backup created successfully${NC}"
}

# Function to restore from backup
restore_backup() {
  echo -e "${YELLOW}Restoring from backup...${NC}"
  
  if [ -d "$CURRENT_BACKUP" ]; then
    # Restore all files from backup
    cp "$CURRENT_BACKUP"/* "$CONFIG_DIR/" 2>/dev/null || true
    
    echo -e "${GREEN}Restored from backup${NC}"
  else
    echo -e "${RED}No backup found to restore${NC}"
    exit 1
  fi
}

# Function to cleanup old backups (keep last 5)
cleanup_old_backups() {
  echo -e "${BLUE}Cleaning up old backups (keeping last 5)...${NC}"
  cd "$BACKUP_DIR"
  ls -t | tail -n +6 | xargs -r rm -rf
  cd "$CONFIG_DIR"
}

# Create backup before doing anything
create_backup

# Save hardware-configuration.nix separately (machine-specific, never from git)
echo -e "${YELLOW}Preserving hardware-configuration.nix...${NC}"
cp hardware-configuration.nix /tmp/hardware-configuration.nix.preserve

# Check if git repo exists and is properly configured
if [ ! -d ".git" ]; then
  echo -e "${YELLOW}No git repository found. Initializing...${NC}"
  git init
  git remote add origin "$REPO_URL" || true
fi

# Fetch latest changes
echo -e "${YELLOW}Fetching from GitHub...${NC}"
if ! git fetch origin main; then
  echo -e "${RED}Failed to fetch from GitHub${NC}"
  echo -e "${YELLOW}Continuing with local configuration...${NC}"
else
  # Reset to match remote (but we'll restore hardware-configuration.nix after)
  echo -e "${YELLOW}Pulling latest changes...${NC}"
  git reset --hard origin/main || {
    echo -e "${RED}Failed to reset to origin/main${NC}"
    restore_backup
    exit 1
  }
fi

# ALWAYS restore the machine-specific hardware-configuration.nix
echo -e "${YELLOW}Restoring machine-specific hardware-configuration.nix...${NC}"
cp /tmp/hardware-configuration.nix.preserve hardware-configuration.nix
rm /tmp/hardware-configuration.nix.preserve

# Make sure hardware-configuration.nix is tracked (but won't be pushed)
git add hardware-configuration.nix 2>/dev/null || true

# Update flake inputs
echo -e "${YELLOW}Updating flake inputs...${NC}"
if ! nix flake update; then
  echo -e "${RED}Failed to update flake inputs${NC}"
  restore_backup
  exit 1
fi

# Rebuild system
echo -e "${YELLOW}Rebuilding system...${NC}"
if ! sudo nixos-rebuild switch --flake .#leavenworth; then
  echo -e "${RED}Failed to rebuild system${NC}"
  echo -e "${YELLOW}Restoring from backup...${NC}"
  restore_backup
  exit 1
fi

# If we got here, everything succeeded
echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Rebuild complete!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Cleanup old backups
cleanup_old_backups

echo -e "${BLUE}Backup saved at: $CURRENT_BACKUP${NC}"
echo -e "${BLUE}To restore this backup manually: sudo cp $CURRENT_BACKUP/* /etc/nixos/${NC}"
