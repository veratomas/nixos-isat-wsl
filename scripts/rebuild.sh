#!/usr/bin/env bash
#
# scripts/rebuild.sh
#
# Day-to-day update: pull whatever the team has already agreed on (the
# committed flake.lock -- see scripts/upgrade-os.sh for *changing* that)
# and rebuild this machine to match. This is the script you run after
# `git pull`-ing changes a teammate made, or just to be sure you're in
# sync before starting work.
#
# Also available as the `rebuild` shell alias (see modules/core.nix)
# from any directory.

set -euo pipefail

info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m==>\033[0m %s\n' "$1"; }
fail()  { printf '\033[1;31m==>\033[0m %s\n' "$1" >&2; exit 1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLAKE_TARGET="wsl"

cd "$REPO_ROOT"

if [ -n "$(git status --porcelain)" ]; then
  fail "You have uncommitted changes in $REPO_ROOT. Commit, stash, or discard them before rebuilding, so a 'git pull' can't silently clobber your work:
  git status"
fi

info "Pulling latest changes..."
if ! git pull --ff-only; then
  fail "git pull --ff-only failed -- your local branch has probably diverged from upstream (e.g. you have local commits). Resolve this manually (rebase or merge), then re-run this script."
fi

info "Rebuilding (sudo nixos-rebuild switch)..."
sudo nixos-rebuild switch --flake ".#${FLAKE_TARGET}"

ok "Rebuild complete."
echo "Current generation:"
nixos-rebuild list-generations 2>/dev/null | tail -n 1 || true
