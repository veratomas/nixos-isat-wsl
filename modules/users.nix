# modules/users.nix
#
# The default developer account. `config.wsl.defaultUser` (set in
# modules/wsl.nix) is what NixOS-WSL logs you into automatically, so this
# module creates a matching, sudo-capable Linux user for it.
{ config, pkgs, lib, ... }:

{
  users.users.${config.wsl.defaultUser} = {
    isNormalUser = true;
    description = "Default developer account (see modules/wsl.nix)";
    extraGroups = [
      "wheel" # sudo access
      "docker" # run `docker` without sudo -- see modules/docker.nix
    ];
    shell = pkgs.nushell; # configured in modules/shell.nix (aliases, Starship prompt); swap for pkgs.bash / pkgs.zsh / pkgs.fish if your team prefers, and update that file to match
  };

  # No password is set here on purpose: NixOS-WSL logs you straight into
  # this user without a login prompt, and this config is meant to be
  # pushed to a public/shared GitHub repo, so a secret must never live in
  # it. If you want a password for `sudo` (e.g. on a shared machine), set
  # one once, interactively, after install:
  #   sudo passwd nixos
  # It's stored in /etc/shadow, not in this repo, and survives rebuilds.

  # Convenience default for a single-user dev VM: `sudo` doesn't prompt
  # for a password at all. Set this to `true` if that's not your team's
  # security policy.
  security.sudo.wheelNeedsPassword = false;
}
