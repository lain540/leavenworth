#!/usr/bin/env bash
# cleanup.sh — remove old generations, collect garbage, optimise the nix store
# Usage: sudo ./scripts/cleanup.sh [--dry-run]
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

KEEP=3          # generations to keep (system + home-manager)
JOURNAL="7d"    # vacuum journal logs older than this
DRY=false

for arg in "$@"; do
  case $arg in
    --dry-run|-n) DRY=true; echo -e "${YELLOW}[dry run] no changes will be made${NC}" ;;
    --help|-h)    echo "Usage: sudo ./scripts/cleanup.sh [--dry-run]"; exit 0 ;;
  esac
done

run() { $DRY && echo -e "${CYAN}[would]${NC} $*" || "$@"; }
sec() { echo -e "\n${BLUE}── $* ──${NC}"; }

sec "disk before"
NIX_BEFORE=$(du -sb /nix/store 2>/dev/null | cut -f1 || echo 0)
echo "nix store: $(numfmt --to=iec-i --suffix=B "$NIX_BEFORE")"

sec "system generations (keeping last $KEEP)"
nix-env --list-generations --profile /nix/var/nix/profiles/system 2>/dev/null || true
run sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations "+${KEEP}"

sec "home-manager generations (keeping last $KEEP)"
HM="/nix/var/nix/profiles/per-user/$USER/home-manager"
if [[ -e $HM ]]; then
  nix-env --list-generations --profile "$HM" 2>/dev/null || true
  run nix-env --profile "$HM" --delete-generations "+${KEEP}"
else
  echo "no home-manager profile found"
fi

sec "garbage collection"
run sudo nix-collect-garbage

sec "store optimisation (hardlink dedup — may take a few minutes)"
run sudo nix-store --optimise

sec "user caches"
for dir in "$HOME/.cache/nix" "$HOME/.cache/thumbnails" "$HOME/.cache/fontconfig"; do
  [[ -d $dir ]] && { sz=$(du -sh "$dir" | cut -f1); echo "clearing $dir ($sz)"; run rm -rf "$dir"; }
done

sec "systemd journal"
echo "current size: $(journalctl --disk-usage 2>/dev/null | grep -oP '[\d.]+ [A-Z]+' | head -1)"
run sudo journalctl --vacuum-time="$JOURNAL"

sec "summary"
if ! $DRY; then
  NIX_AFTER=$(du -sb /nix/store 2>/dev/null | cut -f1 || echo 0)
  SAVED=$(( NIX_BEFORE - NIX_AFTER ))
  echo "before : $(numfmt --to=iec-i --suffix=B "$NIX_BEFORE")"
  echo "after  : $(numfmt --to=iec-i --suffix=B "$NIX_AFTER")"
  [[ $SAVED -gt 0 ]] \
    && echo -e "freed  : ${GREEN}$(numfmt --to=iec-i --suffix=B "$SAVED")${NC}" \
    || echo -e "freed  : ${YELLOW}0 (store may have grown)${NC}"
else
  echo -e "${CYAN}dry run complete — nothing changed${NC}"
fi

echo -e "\n${GREEN}done${NC} — reboot to free any lingering tmpfs memory"
