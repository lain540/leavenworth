#!/usr/bin/env bash
# cleanup.sh - Remove old NixOS generations and clean up cache/temp files
# Usage: sudo ./scripts/cleanup.sh [--dry-run]
#
# What this does:
#   1. Removes old NixOS system generations (keeps last N)
#   2. Removes old home-manager generations (keeps last N)
#   3. Runs nix garbage collection
#   4. Cleans nix store optimisation (deduplication)
#   5. Clears user cache directories
#   6. Clears systemd journal logs older than N days

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Configuration ──────────────────────────────────────────────────────────────
KEEP_GENERATIONS=3       # Number of system generations to keep
KEEP_HM_GENERATIONS=3   # Number of home-manager generations to keep
JOURNAL_KEEP="7d"        # Keep journal logs for this long
DRY_RUN=false

# ── Parse arguments ────────────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --dry-run|-n)
      DRY_RUN=true
      echo -e "${YELLOW}[DRY RUN] No changes will be made${NC}"
      ;;
    --help|-h)
      echo "Usage: sudo ./scripts/cleanup.sh [--dry-run]"
      echo ""
      echo "Options:"
      echo "  --dry-run, -n    Show what would be done without doing it"
      echo "  --help,    -h    Show this help"
      exit 0
      ;;
  esac
done

# ── Helpers ────────────────────────────────────────────────────────────────────
run() {
  if $DRY_RUN; then
    echo -e "${CYAN}[would run]${NC} $*"
  else
    "$@"
  fi
}

section() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}▶ $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

hr() {
  echo -e "${BLUE}────────────────────────────────────────${NC}"
}

bytes_to_human() {
  numfmt --to=iec-i --suffix=B "$1" 2>/dev/null || echo "${1}B"
}

# ── Disk usage before ──────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       Leavenworth System Cleanup       ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"

NIX_STORE_BEFORE=$(du -sb /nix/store 2>/dev/null | cut -f1 || echo 0)
echo ""
echo -e "${YELLOW}Nix store before: $(bytes_to_human $NIX_STORE_BEFORE)${NC}"

# ── 1. System generations ──────────────────────────────────────────────────────
section "NixOS system generations"

echo "Current generations:"
nix-env --list-generations --profile /nix/var/nix/profiles/system 2>/dev/null || true
hr

CURRENT_GEN=$(nix-env --list-generations --profile /nix/var/nix/profiles/system \
  2>/dev/null | grep '(current)' | awk '{print $1}' || echo 0)

echo -e "Keeping last ${YELLOW}${KEEP_GENERATIONS}${NC} generations (current: ${CURRENT_GEN})"

run sudo nix-env \
  --profile /nix/var/nix/profiles/system \
  --delete-generations "+${KEEP_GENERATIONS}"

echo -e "${GREEN}✓ System generations pruned${NC}"

# ── 2. Home-manager generations ───────────────────────────────────────────────
section "Home-manager generations"

HM_PROFILE="/nix/var/nix/profiles/per-user/$USER/home-manager"
if [ -e "$HM_PROFILE" ]; then
  echo "Current home-manager generations:"
  nix-env --list-generations --profile "$HM_PROFILE" 2>/dev/null || true
  hr
  echo -e "Keeping last ${YELLOW}${KEEP_HM_GENERATIONS}${NC} generations"
  run nix-env \
    --profile "$HM_PROFILE" \
    --delete-generations "+${KEEP_HM_GENERATIONS}"
  echo -e "${GREEN}✓ Home-manager generations pruned${NC}"
else
  echo -e "${YELLOW}No home-manager profile found, skipping${NC}"
fi

# ── 3. Nix garbage collection ─────────────────────────────────────────────────
section "Nix garbage collection"

echo "Collecting garbage (unreferenced store paths)..."
run sudo nix-collect-garbage
echo -e "${GREEN}✓ Garbage collection done${NC}"

# ── 4. Nix store optimisation (deduplication) ─────────────────────────────────
section "Nix store optimisation"

echo "Deduplicating identical files in the store (hardlinking)..."
echo -e "${YELLOW}This may take a few minutes...${NC}"
run sudo nix-store --optimise
echo -e "${GREEN}✓ Store optimised${NC}"

# ── 5. User cache ─────────────────────────────────────────────────────────────
section "User cache cleanup"

# Nix eval / flake cache
if [ -d "$HOME/.cache/nix" ]; then
  CACHE_SIZE=$(du -sh "$HOME/.cache/nix" 2>/dev/null | cut -f1)
  echo -e "Clearing nix eval cache (~/.cache/nix) — ${YELLOW}${CACHE_SIZE}${NC}"
  run rm -rf "$HOME/.cache/nix"
fi

# Thumbnail cache
if [ -d "$HOME/.cache/thumbnails" ]; then
  THUMB_SIZE=$(du -sh "$HOME/.cache/thumbnails" 2>/dev/null | cut -f1)
  echo -e "Clearing thumbnail cache — ${YELLOW}${THUMB_SIZE}${NC}"
  run rm -rf "$HOME/.cache/thumbnails"
fi

# fontconfig cache (safe to regenerate)
if [ -d "$HOME/.cache/fontconfig" ]; then
  echo "Clearing fontconfig cache (will regenerate on next app launch)"
  run rm -rf "$HOME/.cache/fontconfig"
fi

echo -e "${GREEN}✓ User caches cleared${NC}"

# ── 6. Systemd journal ────────────────────────────────────────────────────────
section "Systemd journal"

JOURNAL_SIZE=$(journalctl --disk-usage 2>/dev/null | grep -oP '[\d.]+ [A-Z]+' | head -1 || echo "unknown")
echo -e "Current journal size: ${YELLOW}${JOURNAL_SIZE}${NC}"
echo -e "Removing logs older than ${YELLOW}${JOURNAL_KEEP}${NC}..."

run sudo journalctl --vacuum-time="$JOURNAL_KEEP"
echo -e "${GREEN}✓ Journal cleaned${NC}"

# ── 7. Temp files ─────────────────────────────────────────────────────────────
section "Temp files"

# /tmp is usually cleared on reboot via tmpfs, but clean old stuff just in case
if [ -d /tmp ]; then
  echo "Removing /tmp files older than 7 days..."
  run find /tmp -maxdepth 1 -atime +7 -exec rm -rf {} + 2>/dev/null || true
fi

echo -e "${GREEN}✓ Temp files cleaned${NC}"

# ── Summary ───────────────────────────────────────────────────────────────────
section "Summary"

if ! $DRY_RUN; then
  NIX_STORE_AFTER=$(du -sb /nix/store 2>/dev/null | cut -f1 || echo 0)
  SAVED=$((NIX_STORE_BEFORE - NIX_STORE_AFTER))

  echo -e "Nix store before : ${YELLOW}$(bytes_to_human $NIX_STORE_BEFORE)${NC}"
  echo -e "Nix store after  : ${GREEN}$(bytes_to_human $NIX_STORE_AFTER)${NC}"

  if [ "$SAVED" -gt 0 ]; then
    echo -e "Space freed      : ${GREEN}$(bytes_to_human $SAVED)${NC}"
  else
    echo -e "Space freed      : ${YELLOW}0 (store may have grown due to new paths)${NC}"
  fi
else
  echo -e "${CYAN}Dry run complete — no changes were made${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           Cleanup complete!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Tip:${NC} Reboot to free any lingering tmpfs memory"
echo ""
