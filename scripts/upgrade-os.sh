#!/usr/bin/env bash
#
# scripts/upgrade-os.sh
#
# Deliberately moves this flake's pinned inputs (nixpkgs, nixos-wsl,
# rust-overlay) forward, rebuilds against the new versions, and -- if
# that succeeds -- leaves the updated flake.lock staged for you to
# review and commit.
#
# This is DIFFERENT from scripts/rebuild.sh:
#   - rebuild.sh    syncs YOU to whatever flake.lock the team already
#                   agreed on (via `git pull`). Every team member runs
#                   this often; it never changes what versions are used.
#   - upgrade-os.sh CHANGES what flake.lock points to. Treat this as a
#                   deliberate, reviewed action -- ideally one person
#                   runs it, checks nothing broke, opens a PR with the
#                   flake.lock diff, and everyone else picks it up the
#                   normal way via rebuild.sh. If every developer runs
#                   `nix flake update` on their own whenever they like,
#                   you lose the whole point of pinning versions.
#
# Usage:
#   ./scripts/upgrade-os.sh              # update every input
#   ./scripts/upgrade-os.sh nixpkgs      # update just one input

set -euo pipefail

info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m==>\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m==>\033[0m %s\n' "$1"; }
fail()  { printf '\033[1;31m==>\033[0m %s\n' "$1" >&2; exit 1; }

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLAKE_TARGET="wsl"

cd "$REPO_ROOT"

if [ -n "$(git status --porcelain)" ]; then
  fail "You have uncommitted changes in $REPO_ROOT. Commit or stash them first, so it's obvious afterwards that the only diff is flake.lock:
  git status"
fi

info "Pulling latest changes first..."
git pull --ff-only

cp flake.lock flake.lock.bak

if [ $# -gt 0 ]; then
  info "Updating flake input(s): $*"
  nix flake update "$@"
else
  info "Updating all flake inputs (nixpkgs, nixos-wsl, rust-overlay)..."
  nix flake update
fi

if diff -q flake.lock.bak flake.lock >/dev/null 2>&1; then
  rm flake.lock.bak
  ok "Everything was already up to date -- nothing to rebuild."
  exit 0
fi

echo
info "flake.lock changed. Building the new configuration..."
if ! sudo nixos-rebuild switch --flake ".#${FLAKE_TARGET}"; then
  warn "Rebuild failed. Restoring the previous flake.lock..."
  mv flake.lock.bak flake.lock
  fail "Rolled back flake.lock. Nothing was committed. Fix the issue (or update a smaller set of inputs) and try again."
fi

rm flake.lock.bak
ok "Rebuild succeeded on the new versions."
cat <<EOF

Next: review and share this with the team.
  git diff flake.lock
  git add flake.lock
  git commit -m "chore: update flake inputs"
  git push

Everyone else picks this up the normal way, with:
  ./scripts/rebuild.sh
EOF
