#!/usr/bin/env bash
# Rebuild script - pulls latest config from GitHub and rebuilds system

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

CONFIG_DIR="/etc/nixos"
REPO_URL="https://github.com/lain540/leavenworth.git"

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Leavenworth System Rebuild${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Check if we're in the config directory
if [ ! -d "$CONFIG_DIR" ]; then
  echo -e "${RED}Error: $CONFIG_DIR does not exist${NC}"
  exit 1
fi

cd "$CONFIG_DIR"

# Check if it's a git repository
if [ ! -d ".git" ]; then
  echo -e "${YELLOW}Not a git repository. Initializing...${NC}"
  git init
  git remote add origin "$REPO_URL"
fi

echo -e "${YELLOW}Pulling latest changes from GitHub...${NC}"
git pull origin main || {
  echo -e "${RED}Failed to pull from GitHub${NC}"
  echo "Continuing with local configuration..."
}

echo ""
echo -e "${YELLOW}Updating flake inputs...${NC}"
nix flake update

echo ""
echo -e "${YELLOW}Rebuilding system...${NC}"
sudo nixos-rebuild switch --flake .#leavenworth

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Rebuild complete!${NC}"
echo -e "${GREEN}=====================================${NC}"
