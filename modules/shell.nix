# modules/shell.nix
#
# Nushell as the team's default interactive shell, with Starship for the
# prompt. modules/users.nix sets the default user's login shell to
# `pkgs.nushell`; this file provides the actual shell configuration
# (aliases, Starship wiring) and registers it as a valid login shell.
{ pkgs, ... }:

{
  # Needed so Nushell is accepted as a login shell (some tools check
  # /etc/shells before letting you `chsh` or log in with it).
  environment.shells = [ pkgs.nushell ];

  programs.nushell = {
    enable = true;

    # Same shortcuts as the bash aliases in modules/core.nix
    # (`environment.shellAliases`, which Nushell doesn't read), wired up
    # to the scripts in scripts/. Assumes the repo was cloned to the
    # default location used by scripts/bootstrap.sh (~/nixos-config); if
    # you cloned it elsewhere, update these or just run the scripts
    # directly with their full path.
    shellAliases = {
      ll = "ls -la";
      rebuild = "~/nixos-config/scripts/rebuild.sh";
      upgrade-os = "~/nixos-config/scripts/upgrade-os.sh";
      nix-cleanup = "~/nixos-config/scripts/cleanup.sh";
    };

    # Standard way to wire Starship into Nushell (Starship doesn't have
    # first-class Nushell support the way it does for bash/zsh/fish, so
    # it generates its init script into a cache file and we source that):
    # https://starship.rs/guide/#%F0%9F%9A%80-installation
    extraConfig = ''
      mkdir ~/.cache/starship
      starship init nu | save -f ~/.cache/starship/init.nu
      source ~/.cache/starship/init.nu
    '';
  };

  # Installs the `starship` binary and (for bash/zsh/fish) wires up their
  # interactive shell init automatically. Nushell's own wiring is the
  # `extraConfig` block above.
  programs.starship.enable = true;
}
