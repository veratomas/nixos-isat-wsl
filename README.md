# nixos-config (WSL flake-base)

A shared NixOS 26.05 flake configuration for the team's WSL2 development
environments. One `git clone` + one script gets you: git, VS Code,
Docker, a Rust stable toolchain (with the `musl` + `gnu` Linux targets),
a system Python with the project's libraries, PostgreSQL, and
LSPs/formatters for Rust/Python/Nix -- all pinned to the exact same
versions as everyone else on the team.

You do **not** need to know Nix to use this day-to-day. You do need
Nix/NixOS knowledge to *change* it -- see [Extending this
config](#extending-this-config) below, and don't hesitate to ask
whoever on the team is comfortable with it.

## Contents

- [Prerequisites](#prerequisites)
- [First-time setup](#first-time-setup)
- [Day-to-day usage](#day-to-day-usage)
- [Updating the OS (bumping versions)](#updating-the-os-bumping-versions)
- [Repo structure](#repo-structure)
- [Extending this config](#extending-this-config)
- [Git and secrets](#git-and-secrets)
- [Troubleshooting](#troubleshooting)

## Prerequisites

You need Windows 11 (or a recent Windows 10) with WSL2, and the
**NixOS-WSL** distro specifically -- not the default Ubuntu that `wsl
--install` gives you.

1. Make sure WSL2 itself is installed (skip if you already use WSL for
   anything):
   ```powershell
   wsl --install --no-distribution
   ```
2. Install NixOS-WSL. The easiest route is the `.wsl` installer from the
   project's releases page -- download it and double-click it, or from
   PowerShell:
   ```powershell
   winget install --id NixOS.NixOS
   ```
   (If that package ID doesn't resolve for you, grab the latest `.wsl`
   file manually from
   https://github.com/nix-community/NixOS-WSL/releases and double-click
   it.)
3. Launch "NixOS" from the Start Menu once, so it finishes its initial
   setup and drops you into a shell.

From here on, everything happens *inside* that NixOS shell.

## First-time setup

```bash
curl -fsSL https://raw.githubusercontent.com/veratomas/nixos-isat-wsl/main/scripts/bootstrap.sh | bash
```

This will:

- Clone this repo to `~/nixos-config`
- Ask for a **username** and **hostname** for this machine (stored only
  in the gitignored `hosts/wsl/local.nix` -- see
  [Git and secrets](#git-and-secrets))
- Run the first `nixos-rebuild switch`, which installs everything above

The first run downloads a lot and can take a while, especially on a slow
connection -- that's normal.

Prefer to do it by hand instead of curl-piping a script? That's exactly
what the script itself does, so this works too:

```bash
git clone https://github.com/veratomas/nixos-isat-wsl.git ~/nixos-config
cd ~/nixos-config
./scripts/bootstrap.sh
```

When it finishes, follow the printed next steps (git identity, restart
your WSL terminal, sanity-check `docker run --rm hello-world`).

## Day-to-day usage

Whenever you want to pick up changes a teammate made (or just make sure
you're in sync before starting work):

```bash
rebuild
```

(That's a shell alias for `~/nixos-config/scripts/rebuild.sh` -- see
`modules/core.nix`. It's equivalent to `cd ~/nixos-config && git pull &&
sudo nixos-rebuild switch --flake .#wsl`, with some friendlier error
messages.)

This is safe to run often. If it fails, it tells you why (uncommitted
local changes, a diverged branch, a build error) rather than leaving
things half-applied -- a NixOS rebuild either fully succeeds or your
previous, working configuration keeps running.

Made a mistake and want to go back? NixOS keeps old configurations
around as boot/rebuild "generations":

```bash
# roll back to the previous generation:
sudo nixos-rebuild switch --rollback

# or see them all:
nixos-rebuild list-generations
```

## Updating the OS (bumping versions)

`rebuild` (above) only ever syncs you to versions the **team has already
agreed on** -- it never changes what those versions are. That's
controlled by `flake.lock`, a file that pins the exact commit of
nixpkgs, NixOS-WSL, and rust-overlay everyone builds against.

Moving those pins forward (e.g. to get a newer Rust, or pull in a NixOS
security fix) is a deliberate action, not something everyone does
whenever they feel like it -- otherwise "reproducible for the team"
stops being true. The convention:

```bash
upgrade-os
```

This updates `flake.lock`, rebuilds *locally* against the new versions,
and -- only if that rebuild succeeds -- leaves the updated `flake.lock`
staged for you to review, commit, and push (see
`scripts/upgrade-os.sh` for exact behavior, including automatic
rollback if the rebuild fails). Whoever runs this should:

1. Run `upgrade-os`
2. Confirm their machine still works properly (open the editors, run a
   build, etc.)
3. Open a PR with just the `flake.lock` diff
4. Once merged, everyone else picks it up the normal way, with `rebuild`

## Repo structure

```
flake.nix                        entry point: inputs, and the "wsl" system definition
hosts/wsl/
  default.nix                    host-specific settings: hostname, timezone, imports
  local.nix.example              template for your personal, gitignored overrides
modules/
  core.nix                       Nix daemon settings, locale, shell aliases
  wsl.nix                        WSL2 integration + GUI/GPU passthrough
  docker.nix                     native Docker daemon + docker-compose
  users.nix                      the default user account
  git.nix                        system-wide git config
  secrets.nix                    documentation only -- see "where do secrets go?"
  packages/
    editors.nix                  VS Code
    rust.nix                     Rust stable toolchain (rust-overlay) + targets
    python.nix                   Python + project libraries + pyright/ruff
    nix-tooling.nix              nixd + nixfmt, for editing this repo
    dev-tools.nix                git, gcc, glibc, openssl, zbar, misc CLI tools
    services.nix                 PostgreSQL
scripts/
  bootstrap.sh                   first-time setup (see above)
  rebuild.sh                     day-to-day pull + rebuild (the `rebuild` alias)
  upgrade-os.sh                  deliberate version bumps (the `upgrade-os` alias)
  cleanup.sh                     free disk space (the `nix-cleanup` alias)
```

Every file above has comments explaining the *why*, not just the *what*
-- if something looks surprising, read the comments in that file before
asking around.

## Extending this config

**Add a package:** find its exact name at
https://search.nixos.org/packages, then add it to the most relevant
`modules/packages/*.nix` file's `environment.systemPackages` list (or
`modules/packages/dev-tools.nix` if nothing else fits), then `rebuild`.
Every packages file has a comment at the bottom showing the pattern.

**Add a Python library:** add it to the list in
`modules/packages/python.nix`.

**Add a Rust target or toolchain component:** edit the `targets` /
`extensions` lists in `modules/packages/rust.nix`.

**Add a whole new module:** create `modules/whatever.nix` (or
`modules/packages/whatever.nix`), then add it to the `imports` list in
`hosts/wsl/default.nix`.

Format everything with `nix fmt` before committing (uses the official
Nix formatter, `nixfmt`, across the whole repo).

## Git and secrets

**Git identity:** not set by this config on purpose -- run once, per
machine:

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

**Your username and hostname:** `scripts/bootstrap.sh` asks for these on
first install and writes them to `hosts/wsl/local.nix`. Want to change
them later, or set them by hand? Copy `hosts/wsl/local.nix.example` to
`hosts/wsl/local.nix` and edit the `wsl.defaultUser` /
`networking.hostName` lines -- see the comments in `modules/wsl.nix` for
why it's best to decide these *before* your first rebuild rather than
after.

**Secrets in general (API tokens, DB passwords, registry credentials):** never go
in a tracked `*.nix` file -- this repo is meant to live on GitHub.
`hosts/wsl/local.nix` (gitignored) is the place for anything
machine-specific or sensitive; see the comments in `modules/secrets.nix`
for the full picture, including how to graduate to `sops-nix`/`agenix`
later if the team ends up needing to *share* encrypted secrets rather
than keep them per-machine. Application-level secrets (e.g. a Telegram
bot token for a Python project built with the `python-dotenv` library
installed here) belong in that project's own `.env` file, not in this
system config.

## Troubleshooting

**VS Code won't open a window, or is very slow / choppy.** This is
WSLg's job, and `wsl.useWindowsDriver = true` in `modules/wsl.nix` is
what makes it GPU-accelerated instead of CPU-rendered. Try `wsl
--shutdown` from PowerShell and reopening your terminal first (WSLg
occasionally needs a fresh session after a Windows update).

**`docker` says "permission denied" or "Cannot connect to the Docker
daemon".** You likely need to close and reopen your WSL terminal (or
`wsl --shutdown` from PowerShell and reopen) after your first rebuild so
your user's new "docker" group membership takes effect -- see
`modules/users.nix` and `modules/docker.nix`. If it still can't connect,
check that the daemon is actually running: `systemctl status docker`.

**The Nix store / your WSL disk is taking up a lot of space.** Run
`nix-cleanup` (`scripts/cleanup.sh`). It also prints the PowerShell
commands to compact the underlying `.vhdx` on the Windows side, if you
need that too.

**`rebuild` fails with "you have uncommitted changes".** That's
intentional -- it refuses to `git pull` over local edits it might
silently discard. Commit, stash, or discard them (`git status` to see
what's there), then run `rebuild` again.

**A rebuild fails partway through.** Your previous, working
configuration is still what's running -- NixOS never leaves you in a
half-updated state. Fix the underlying issue (read the error; it's
usually a typo'd package name or a real syntax error) and `rebuild`
again, or ask for help with the exact error message.
