#!/usr/bin/env bash
# Fix ownership and setup GitHub authentication

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Leavenworth Setup Helper${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""

# Fix 1: Change ownership of /etc/nixos to svea
echo -e "${YELLOW}Fixing /etc/nixos ownership...${NC}"
sudo chown -R svea:users /etc/nixos

echo -e "${GREEN}✓ Ownership fixed! You can now use git without sudo.${NC}"
echo ""

# Fix 2: Setup SSH key for GitHub
echo -e "${YELLOW}Setting up GitHub SSH authentication...${NC}"
echo ""

SSH_KEY="$HOME/.ssh/id_ed25519"

if [ -f "$SSH_KEY" ]; then
  echo -e "${BLUE}SSH key already exists at $SSH_KEY${NC}"
else
  echo -e "${YELLOW}Generating new SSH key...${NC}"
  ssh-keygen -t ed25519 -C "lain540@github" -f "$SSH_KEY" -N ""
  echo -e "${GREEN}✓ SSH key generated${NC}"
fi

# Start SSH agent and add key
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY"

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Next Steps:${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "${YELLOW}1. Copy your SSH public key:${NC}"
echo ""
cat "$SSH_KEY.pub"
echo ""
echo -e "${YELLOW}2. Add it to GitHub:${NC}"
echo "   - Go to: https://github.com/settings/keys"
echo "   - Click 'New SSH key'"
echo "   - Paste the key above"
echo "   - Click 'Add SSH key'"
echo ""
echo -e "${YELLOW}3. Switch your git remote to SSH:${NC}"
echo "   cd /etc/nixos"
echo "   git remote set-url origin git@github.com:lain540/leavenworth.git"
echo ""
echo -e "${YELLOW}4. Test the connection:${NC}"
echo "   ssh -T git@github.com"
echo ""
echo -e "${YELLOW}5. Now you can push:${NC}"
echo "   cd /etc/nixos"
echo "   git push -u origin main"
echo ""
