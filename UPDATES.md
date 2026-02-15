# Updated Configuration Files

## What's New

### 1. Fish Shell (configuration.nix + home.nix)
- Fish is now the default shell for user `svea`
- System-wide Fish enabled in configuration.nix
- Fish aliases added in home.nix:
  - `rebuild` - Quick rebuild command
  - `update` - Pull from GitHub and rebuild

### 2. musnix (configuration.nix)
- Enabled for audio production optimization
- Real-time kernel enabled
- rtirq enabled for better audio performance

### 3. nixvim (home.nix + flake.nix)
- Minimal Neovim configuration via nixvim
- LSP support for: Lua, Nix, Rust, C, Python
- Treesitter syntax highlighting
- Base16 color scheme
- Plugins: neo-tree, telescope, lualine, nvim-cmp

### 4. Workman Keymap (configuration.nix)
- Console keymap set to Workman layout
- Active in TTY/console mode

### 5. Rebuild Script (rebuild.sh)
- **NEW:** Automatically creates timestamped backups before rebuilding
- **NEW:** Restores from backup if anything fails
- **NEW:** Keeps last 5 backups, cleans up older ones
- Pulls latest config from GitHub by cloning fresh
- Updates flake inputs
- Rebuilds system
- Usage: `sudo ./rebuild.sh`

## Current Git Error Fix

If you're getting the "untracked working tree files would be overwritten" error:

### Quick Fix (Run this once):
```bash
cd /etc/nixos
sudo chmod +x fix-git.sh
sudo ./fix-git.sh
```

This will:
1. Backup your current config to `backups/manual_backup/`
2. Remove the problematic git repo
3. Clone fresh from GitHub
4. Set up git properly

After running, you can use `sudo ./rebuild.sh` normally.

## Installation

1. Replace your existing files in `/etc/nixos/` with these updated ones:
   ```bash
   cd /etc/nixos
   # Backup old config
   sudo cp configuration.nix configuration.nix.backup
   sudo cp home.nix home.nix.backup
   sudo cp flake.nix flake.nix.backup
   
   # Copy new files (from wherever you downloaded them)
   sudo cp /path/to/configuration.nix .
   sudo cp /path/to/home.nix .
   sudo cp /path/to/flake.nix .
   sudo cp /path/to/rebuild.sh .
   sudo chmod +x rebuild.sh
   ```

2. Rebuild the system:
   ```bash
   sudo nixos-rebuild switch --flake /etc/nixos#leavenworth
   ```

3. After rebuild, Fish will be your default shell
4. Log out and back in to activate Fish

## Using the Rebuild Script

To use the automatic rebuild script:

```bash
cd /etc/nixos
sudo ./rebuild.sh
```

This will:
1. **Create a timestamped backup** in `/etc/nixos/backups/YYYYMMDD_HHMMSS/`
2. Clone latest changes from https://github.com/lain540/leavenworth.git
3. Update flake inputs
4. Rebuild the system
5. **If anything fails, automatically restore from backup**
6. Keep last 5 backups, delete older ones

### Manual Backup Restore

If you need to manually restore a backup:
```bash
# List available backups
ls -la /etc/nixos/backups/

# Restore from a specific backup
sudo cp /etc/nixos/backups/20260215_120000/* /etc/nixos/
sudo nixos-rebuild switch --flake /etc/nixos#leavenworth
```

## Notes

- **musnix** will switch to a real-time kernel on first rebuild (requires reboot)
- **nixvim** is minimal - you can extend it in home.nix
- **Julia** LSP not included yet (can be added if needed)
- Make sure to push your `/etc/nixos` to GitHub at https://github.com/lain540/leavenworth.git
