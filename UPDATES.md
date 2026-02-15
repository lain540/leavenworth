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
- Pulls latest config from GitHub
- Updates flake inputs
- Rebuilds system
- Usage: `./rebuild.sh`

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
./rebuild.sh
```

This will:
1. Pull latest changes from https://github.com/lain540/leavenworth.git
2. Update flake inputs
3. Rebuild the system

Or use the Fish alias:
```bash
update
```

## Notes

- **musnix** will switch to a real-time kernel on first rebuild (requires reboot)
- **nixvim** is minimal - you can extend it in home.nix
- **Julia** LSP not included yet (can be added if needed)
- Make sure to push your `/etc/nixos` to GitHub at https://github.com/lain540/leavenworth.git
