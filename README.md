# Leavenworth NixOS Config

Minimal NixOS flake configuration for music production and creative work.

## Features

- **Fish Shell**: Set as default shell for user `svea`
- **musnix**: Low-latency audio setup with realtime kernel
- **nixvim**: Neovim configured with LSP, treesitter, and language support
  - Languages: Nix, Lua, Python, Rust, C, Julia, Bash
  - Base16 colorscheme
  - Autocompletion

## Install

### Partitioning (UEFI)

```bash
# Create partitions
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary 512MiB 100%

# Format
mkfs.fat -F 32 -n boot /dev/sda1
mkfs.ext4 -L nixos /dev/sda2

# Mount
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### Install

1. Boot NixOS ISO
2. Partition and mount disk to `/mnt` (see above)
3. Run: `./install.sh /mnt`

## Rebuild

```bash
sudo nixos-rebuild switch --flake /etc/nixos#leavenworth

# Or use Fish alias:
rebuild
```

## User

- **svea** (password: `changeme` - change immediately!)
- Default shell: Fish
- Member of: wheel, audio, video, input, dialout, plugdev, storage, optical, scanner, lp

## Audio

musnix is enabled with realtime kernel for low-latency audio production. Your user is already in the `audio` group.

## Neovim

Configured via nixvim with:
- LSP servers: Nix (nil_ls), Rust, Lua, Python
- Treesitter syntax highlighting
- Autocompletion
- Base16 dark colorscheme

## VirtualBox

Uncomment these lines in `configuration.nix` when testing in VM:
```nix
virtualisation.virtualbox.guest.enable = true;
virtualisation.virtualbox.guest.x11 = true;
```

Remove before deploying to real hardware.

## Inputs

- **nixpkgs**: unstable
- **home-manager**: user configuration
- **hyprland**: window manager (ready for future use)
- **musnix**: audio optimization ✓
- **nixvim**: neovim config ✓

## Structure

```
.
├── flake.nix              # Main config with all inputs
├── configuration.nix      # System config (musnix, fish)
├── home.nix              # User config (nixvim, fish shell)
├── hardware-configuration.nix  # Hardware (auto-generated)
└── install.sh            # Install script
```
