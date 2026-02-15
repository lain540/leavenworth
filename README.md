# Leavenworth

NixOS configuration for music production and creative work.

## Install

```bash
./scripts/install.sh /mnt
```

## Rebuild

```bash
sudo nixos-rebuild switch --flake /etc/nixos#leavenworth
```

## Update from GitHub

```bash
sudo ./scripts/rebuild.sh
```

## Structure

```
.
├── flake.nix           # Flake configuration
├── configuration.nix   # System configuration
├── home.nix           # User configuration
└── scripts/
    ├── install.sh     # Installation script
    └── rebuild.sh     # Update and rebuild script
```
