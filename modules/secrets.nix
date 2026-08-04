# modules/secrets.nix
#
# This file intentionally contains no secrets and does nothing on its
# own -- it exists so "where do secrets go?" has one obvious place to
# look. This repo gets pushed to GitHub, so anything sensitive (API
# tokens, database passwords, registry credentials, ...) must never be
# written directly into a tracked *.nix file.
#
# Two supported patterns, simplest first:
#
# 1) Per-machine local override (already wired up, zero extra setup)
#    -----------------------------------------------------------------
#    Copy hosts/wsl/local.nix.example to hosts/wsl/local.nix -- that
#    exact filename is gitignored (see .gitignore) -- and put
#    machine-specific values there: a Docker registry credential, a
#    personal timezone override, etc.
#    hosts/wsl/default.nix imports it automatically if it exists, and
#    happily builds without it if it doesn't (e.g. on a fresh clone).
#
# 2) sops-nix / agenix (once you have secrets that need to be *shared*
#    across the team, e.g. a staging DB password everyone needs)
#    -----------------------------------------------------------------
#    These encrypt secrets in the repo itself, keyed to each developer's
#    SSH/age key, so they can be committed safely and decrypted only by
#    people who should have them. Deliberately left out of this base
#    config to keep the flake's dependency graph small for a team that's
#    still ramping up on Nix -- but it's a well-trodden path if/when you
#    need it:
#      - https://github.com/Mic92/sops-nix
#      - https://github.com/ryantm/agenix
#    Loop in whoever maintains this repo before introducing either, so
#    the whole team migrates together rather than half-adopting it.
#
# A note on the Python project in modules/packages/python.nix
# (python-telegram-bot, python-dotenv, httpx, ...): runtime secrets like
# bot tokens belong in a regular `.env` file *inside that project's own
# repo*, loaded with python-dotenv, with that repo's own .gitignore
# excluding it. That's an application-level concern for the project
# repo, not something this machine-level system flake should manage.
{ ... }:
{
  # Nothing to configure here -- see the comments above.
}
