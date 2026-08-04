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
  environment.shells = [ pkgs.nu ];

  # Installs the `starship` binary and (for bash/zsh/fish) wires up their
  # interactive shell init automatically. Nushell's own wiring is the
  # `extraConfig` block above.
  programs.starship.enable = true;
}
