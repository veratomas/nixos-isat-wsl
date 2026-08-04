# hosts/wsl/default.nix
#
# The "wsl" NixOS system defined in flake.nix. This is the one place
# meant to hold host-specific / personal-taste settings (hostname,
# timezone); shared team policy and package lists live in ../../modules.
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/core.nix
    ../../modules/wsl.nix
    ../../modules/docker.nix
    ../../modules/users.nix
    ../../modules/git.nix
    ../../modules/secrets.nix
    ../../modules/shell.nix
    ../../modules/fonts.nix

    ../../modules/packages/editors.nix
    ../../modules/packages/terminals.nix
    ../../modules/packages/rust.nix
    ../../modules/packages/python.nix
    ../../modules/packages/nix-tooling.nix
    ../../modules/packages/dev-tools.nix
    ../../modules/packages/services.nix
  ]
  # Optional per-machine overrides/secrets (gitignored). See
  # modules/secrets.nix for what this is for. Only imported when present,
  # so a fresh clone with no local.nix yet still builds fine.
  ++ lib.optional (builtins.pathExists ./local.nix) ./local.nix;

  # Shows up in `hostname`, shell prompts, etc. Purely cosmetic, and
  # per-developer -- these are `mkDefault` specifically so that
  # hosts/wsl/local.nix (gitignored, one per machine) can override them
  # with a plain assignment with no conflict. Copy
  # hosts/wsl/local.nix.example to hosts/wsl/local.nix to set your own;
  # you only need to touch this file if you want to change the *team's*
  # fallback default.
  networking.hostName = lib.mkDefault "nixos-wsl";

  # Same deal as hostName above: this is just the fallback. Override per
  # machine in hosts/wsl/local.nix, e.g.:
  #   time.timeZone = "America/Argentina/Mendoza";
  # Full list of valid values:
  # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  time.timeZone = lib.mkDefault "UTC";

  # This tracks the NixOS release this system was FIRST installed with --
  # it is not a "keep this equal to the nixpkgs version" knob, and
  # bumping it doesn't get you new packages (that's what `nix flake
  # update` + scripts/upgrade-os.sh are for). It exists so NixOS knows
  # which one-time data migrations have already run. Leave this alone
  # once it's set; see the NixOS manual's notes on `system.stateVersion`
  # if you're curious why changing it can be unsafe.
  system.stateVersion = "26.05";
}
