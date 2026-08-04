#!/usr/bin/env bash
#
# scripts/bootstrap.sh
#
# One-time setup for a brand-new NixOS-WSL installation: clones this repo
# and does the first `nixos-rebuild switch`. Run it once, from inside
# your fresh NixOS-WSL terminal -- see the README's "First-time setup"
# section for the couple of steps that happen before this, on the
# Windows side (installing WSL2 + the NixOS-WSL distro itself).
#
# Safe to re-run if it fails partway through.
#
# Usage (after cloning this repo yourself):
#   ./scripts/bootstrap.sh
#
# Or, on a totally fresh machine, before you have the repo at all:
#   curl -fsSL https://raw.githubusercontent.com/<YOUR_ORG>/<YOUR_REPO>/main/scripts/bootstrap.sh | bash
#
# This just clones the repo and runs the first rebuild -- it uses the
# team's fallback username/hostname (see modules/wsl.nix and
# hosts/wsl/default.nix). If you want your own, copy
# hosts/wsl/local.nix.example to hosts/wsl/local.nix (gitignored, never
# committed -- see modules/secrets.nix) and edit it, either before or
# after running this script. REPO_URL and CLONE_DIR can be overridden via
# environment variables if you don't want the defaults, e.g. for a
# scripted/non-interactive install:
#   CLONE_DIR=/opt/nixos-config ./scripts/bootstrap.sh

set -euo pipefail

# TODO: update this once the repo has a real home on GitHub.
REPO_URL="${REPO_URL:-https://github.com/veratomas/nixos-isat-wsl.git}"
CLONE_DIR="${CLONE_DIR:-$HOME/nixos-config}"
FLAKE_TARGET="wsl" # matches `nixosConfigurations.wsl` in flake.nix

# --- tiny output helpers ----------------------------------------------
info()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m==>\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m==>\033[0m %s\n' "$1"; }
fail()  { printf '\033[1;31m==>\033[0m %s\n' "$1" >&2; exit 1; }

# --- sanity checks -------------------------------------------------------
command -v nix >/dev/null 2>&1 || fail "The 'nix' command wasn't found. This script must be run inside an already-installed NixOS-WSL distro (Nix ships with it) -- see the README's first-time setup steps."
command -v nixos-rebuild >/dev/null 2>&1 || fail "'nixos-rebuild' wasn't found -- this doesn't look like a NixOS system. Are you sure you're inside the NixOS-WSL distro (not e.g. Ubuntu)?"

if [ "$REPO_URL" = "https://github.com/<YOUR_ORG>/<YOUR_REPO>.git" ]; then
  warn "REPO_URL still has its placeholder value. If this script was run via curl from a real repo, that's a bug in this template -- please update scripts/bootstrap.sh's REPO_URL default (and this check) once you know your repo's URL."
fi

# --- clone (or reuse) the repo ------------------------------------------
if [ -d "$CLONE_DIR/.git" ]; then
  ok "Found an existing clone at $CLONE_DIR, reusing it."
elif [ -e "$CLONE_DIR" ]; then
  fail "$CLONE_DIR already exists but isn't a git repo. Move it aside or set CLONE_DIR to a different path and re-run."
else
  info "Cloning $REPO_URL into $CLONE_DIR ..."
  if command -v git >/dev/null 2>&1; then
    git clone "$REPO_URL" "$CLONE_DIR"
  else
    # Fresh NixOS-WSL images don't ship git by default. `nix-shell`
    # works without flakes being enabled, so it's the most compatible
    # way to borrow git just for this one command.
    info "git isn't installed yet -- borrowing it via nix-shell for this clone."
    nix-shell -p git --run "git clone '$REPO_URL' '$CLONE_DIR'"
  fi
fi

cd "$CLONE_DIR"

# --- first rebuild ---------------------------------------------------
# Flakes are an "experimental" Nix feature that this repo's own config
# turns on permanently (see modules/core.nix) -- but that config can't
# take effect until the *first* rebuild has already run. The
# --option flag below enables flakes just for this one bootstrap
# command, without needing to hand-edit /etc/nix/nix.conf first.
info "Running the first rebuild -- this downloads a lot on a fresh machine and can take a while."
sudo nixos-rebuild switch \
  --flake ".#${FLAKE_TARGET}" \
  --option experimental-features "nix-command flakes"

ok "Done! Your machine is now configured."
cat <<'EOF'

Next steps:
  1. Set your git identity (once, ever):
       git config --global user.name  "Your Name"
       git config --global user.email "you@example.com"

  1a. (Optional) Want your own username/hostname instead of the team
      fallback? Copy hosts/wsl/local.nix.example to hosts/wsl/local.nix,
      edit wsl.defaultUser / networking.hostName, and rebuild -- see the
      README's "Git and secrets" section.

  2. Close and reopen your WSL terminal (or run `wsl --shutdown` from
     PowerShell and reopen) so shell aliases and group membership changes
     (including being added to the "docker" group) take full effect.

  3. Sanity-check Docker:
       docker run --rm hello-world

From now on:
  - Day-to-day updates:      ./scripts/rebuild.sh      (or the `rebuild` alias)
  - Bump to newer versions:  ./scripts/upgrade-os.sh    (or the `upgrade-os` alias)
  - Free up disk space:      ./scripts/cleanup.sh       (or the `nix-cleanup` alias)

See the README for more, including how to add packages and where secrets go.
EOF
