# modules/core.nix
#
# Base system configuration shared by the whole team. Nix daemon settings
# and general "quality of life" defaults live here. Package lists live in
# modules/packages/*.nix instead, and host-specific / personal-taste
# settings (hostname, timezone, username) live in hosts/wsl/default.nix --
# this file should rarely need touching.
{ config, pkgs, lib, ... }:

{
  # ---------------------------------------------------------------------
  # Nix itself
  # ---------------------------------------------------------------------
  nix = {
    settings = {
      # Flakes + the new `nix` CLI are still officially "experimental" but
      # are what this entire config is built on, so they're turned on
      # globally rather than needing --extra-experimental-features on
      # every command.
      experimental-features = [ "nix-command" "flakes" ];

      # Anyone who can sudo (i.e. is in "wheel") can also manage
      # substituters/caches without needing to hand-edit this file.
      trusted-users = [ "root" "@wheel" ];

      # Keep the Nix store tidy automatically (dedupes identical files via
      # hardlinks) instead of relying on everyone remembering to do it.
      auto-optimise-store = true;

      # Add extra binary caches here if your team uses any, e.g. for
      # faster rebuilds via Cachix:
      # substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
      # trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };

    # Automatic garbage collection so the Nix store (and therefore the WSL
    # virtual disk) doesn't grow forever. See also scripts/cleanup.sh for
    # an on-demand, more aggressive clean.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # ---------------------------------------------------------------------
  # Locale
  # ---------------------------------------------------------------------
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = lib.mkDefault "us";

  # ---------------------------------------------------------------------
  # Quality of life
  # ---------------------------------------------------------------------

  # Skip building the local HTML manual on every rebuild -- nobody reads
  # it from a WSL machine, and it noticeably speeds up `nixos-rebuild`.
  documentation.nixos.enable = false;

  environment.shellAliases = {
    ll = "ls -la";

    # Team convenience shortcuts, wired up to the scripts in scripts/.
    # These assume the repo was cloned to the default location used by
    # scripts/bootstrap.sh ($HOME/nixos-config). If you cloned it
    # somewhere else, either update the paths below or just run the
    # scripts directly with their full path.
    rebuild = "$HOME/nixos-config/scripts/rebuild.sh";
    upgrade-os = "$HOME/nixos-config/scripts/upgrade-os.sh";
    nix-cleanup = "$HOME/nixos-config/scripts/cleanup.sh";
  };

  # A handful of genuinely useful, near-universal CLI tools that don't
  # belong to any particular language module.
  environment.systemPackages = with pkgs; [
    curl
    wget
    unzip
    tree
    htop
  ];
}
