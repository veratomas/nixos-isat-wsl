#!/usr/bin/env bash
#
# scripts/cleanup.sh
#
# Frees up disk space by removing old, no-longer-referenced NixOS
# generations and Nix store paths. Safe to run any time -- it can only
# delete things nothing on the system currently depends on, and it will
# never touch the generation you're currently running.
#
# modules/core.nix already runs a lighter version of this automatically
# every week (nix.gc.automatic); this script is for "I need space back
# right now" or "let me also compact the underlying WSL disk image".

set -euo pipefail

info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m==>\033[0m %s\n' "$1"; }

info "Nix store usage before cleanup:"
du -sh /nix/store 2>/dev/null || true

info "Removing old system generations and unreachable store paths..."
sudo nix-collect-garbage --delete-older-than 14d

info "Deduplicating identical files in the store (hardlinking)..."
nix store optimise

ok "Nix store usage after cleanup:"
du -sh /nix/store 2>/dev/null || true

cat <<'EOF'

Note: freeing space *inside* the Nix store doesn't automatically shrink
the underlying WSL virtual disk (.vhdx) on the Windows side -- WSL2 disks
grow but don't auto-shrink. If you need to reclaim that too, run this
from PowerShell (as Administrator) on Windows, with this distro shut down:

  wsl --shutdown
  diskpart
  # then, inside diskpart:
  select vdisk file="<path to your ext4.vhdx, find it with `wsl --list -v` / distro settings>"
  attach vdisk readonly
  compact vdisk
  detach vdisk
  exit

This step is optional and only affects Windows-side disk usage, not
anything inside NixOS -- most people never need to do it.
EOF
