#!/usr/bin/env bash
# Leavenworth NixOS install script
# Usage: sudo ./install.sh /mnt
#
# Run from a NixOS live ISO after partitioning and mounting your target disk.
# Clones the stable branch directly from GitHub, generates hardware config,
# installs the system, then hands ownership of /etc/nixos to svea so she can
# git pull/push without sudo after first boot.
#
# Core dump fix: nix-daemon must be running and the evaluation cache must be
# pre-warmed before nixos-install runs. Both are handled below.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${GREEN}==>${NC} $*"; }
warn()    { echo -e "${YELLOW}==>${NC} $*"; }
error()   { echo -e "${RED}==> ERROR:${NC} $*" >&2; }
section() { echo -e "\n${BLUE}──────────────────────────────────────${NC}"; \
            echo -e "${BLUE}  $*${NC}"; \
            echo -e "${BLUE}──────────────────────────────────────${NC}"; }

REPO="https://github.com/lain540/leavenworth.git"
BRANCH="stable"
TARGET_DIR="/mnt/etc/nixos"
SVEA_UID=1000
SVEA_GID=100  # users group

# ── Checks ────────────────────────────────────────────────────────────────────

[[ $EUID -ne 0 ]] && { error "Run as root: sudo ./install.sh /mnt"; exit 1; }
[[ $# -ne 1 ]]    && { echo "Usage: $0 /mnt"; exit 1; }

MOUNT_POINT="$1"

mountpoint -q "$MOUNT_POINT" || {
  error "$MOUNT_POINT is not mounted. Mount your target disk first."
  exit 1
}

section "Leavenworth NixOS Installer"
info "Repo   : $REPO ($BRANCH)"
info "Target : $MOUNT_POINT"

# ── Step 1: nix-daemon ────────────────────────────────────────────────────────
section "Step 1/5 — Starting nix daemon"
if ! systemctl is-active --quiet nix-daemon 2>/dev/null; then
  warn "nix-daemon not running — starting it"
  systemctl start nix-daemon
  sleep 2
fi
info "nix-daemon running"

# ── Step 2: Enable flakes ─────────────────────────────────────────────────────
section "Step 2/5 — Enabling flakes"
export NIX_CONFIG="experimental-features = nix-command flakes"

# ── Step 3: Clone config + generate hardware config ───────────────────────────
section "Step 3/5 — Cloning config and generating hardware config"

# Remove any leftover nixos dir from a previous failed attempt
rm -rf "$TARGET_DIR"
mkdir -p "$(dirname "$TARGET_DIR")"

info "Cloning $BRANCH branch..."
git clone --branch "$BRANCH" --depth 1 "$REPO" "$TARGET_DIR"

info "Generating hardware-configuration.nix for this machine..."
nixos-generate-config --root "$MOUNT_POINT"
# nixos-generate-config overwrites the hardware-configuration.nix that came from
# git with one freshly detected for this machine. After first boot, commit the
# new hardware-configuration.nix: git add hardware-configuration.nix && git commit
info "hardware-configuration.nix generated"

# ── Step 4: Pre-warm evaluation cache ────────────────────────────────────────
# Without this, the nix evaluator can crash on first run with an empty cache.
section "Step 4/5 — Pre-warming nix evaluation cache"
nix flake metadata "$TARGET_DIR" --no-update-lock-file 2>/dev/null || \
  nix flake metadata "$TARGET_DIR" || true
info "Cache warmed"

# ── Step 5: Install ───────────────────────────────────────────────────────────
section "Step 5/5 — Installing NixOS"
nixos-install \
  --root "$MOUNT_POINT" \
  --flake "$TARGET_DIR#leavenworth" \
  --no-root-passwd \
  --show-trace

# ── Hand ownership to svea ────────────────────────────────────────────────────
# svea owns /etc/nixos so she can git pull/push and edit configs without sudo.
# nixos-rebuild switch still requires sudo — that's expected and correct.
info "Setting ownership of /etc/nixos to svea (uid $SVEA_UID)..."
chown -R "$SVEA_UID:$SVEA_GID" "$MOUNT_POINT/etc/nixos"

# ── Done ──────────────────────────────────────────────────────────────────────
section "Installation complete"
echo ""
echo -e "  ${YELLOW}Next steps:${NC}"
echo "  1. Reboot:              reboot"
echo "  2. Login:               svea / changeme"
echo "  3. Change password:     passwd"
echo "  4. Read workflow:       cat /etc/nixos/WORKFLOW.md"
echo ""
echo -e "  ${YELLOW}If Hyprland doesn't start:${NC}"
echo "  - greetd log:  journalctl -u greetd -e"
echo "  - HM log:      journalctl -u home-manager-svea.service -e"
echo ""
