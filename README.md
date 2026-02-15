# Leavenworth NixOS Config

Minimal NixOS flake configuration for music production and creative work.

## Install

1. Boot NixOS ISO
2. Partition and mount disk to `/mnt`
3. Run: `./install.sh /mnt`

## Rebuild

```bash
sudo nixos-rebuild switch --flake /etc/nixos#leavenworth
```

## User

- **svea** (password: `changeme` - change immediately!)
- Member of: wheel, audio, video, input, dialout, plugdev, storage, optical, scanner, lp

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
- **hyprland**: window manager (for future use)
- **musnix**: audio optimization (for future use)
- **nixvim**: neovim config (for future use)

## Structure

```
.
├── flake.nix              # Main config
├── configuration.nix      # System config
├── home.nix              # User config
└── install.sh            # Install script
```

Note: `hardware-configuration.nix` is auto-generated during installation.
