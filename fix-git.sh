#!/usr/bin/env bash
# Quick fix for the current git error
# Run this once to get your system working

set -e

cd /etc/nixos

echo "Backing up current config..."
mkdir -p backups/manual_backup
cp *.nix *.sh *.md .gitignore backups/manual_backup/ 2>/dev/null || true

echo "Removing git repo..."
sudo rm -rf .git

echo "Cloning fresh from GitHub..."
git clone https://github.com/lain540/leavenworth.git /tmp/leavenworth-temp

echo "Copying files..."
sudo cp /tmp/leavenworth-temp/* /etc/nixos/
sudo cp /tmp/leavenworth-temp/.gitignore /etc/nixos/

echo "Cleaning up..."
rm -rf /tmp/leavenworth-temp

echo "Initializing git..."
git init
git remote add origin https://github.com/lain540/leavenworth.git
git add .
git commit -m "Fresh start"

echo "Done! Now you can run: sudo nixos-rebuild switch --flake /etc/nixos#leavenworth"
