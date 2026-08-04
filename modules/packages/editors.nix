# modules/packages/editors.nix
#
# Text editors. Kate is a GUI app, installed as a native Linux build and
# forwarded to your Windows desktop by WSLg -- this is the "window
# passthrough" that modules/wsl.nix's `wsl.useWindowsDriver = true` makes
# fast (GPU accelerated) instead of software-rendered. Helix is a
# terminal (TUI) editor, so it just runs directly in whichever terminal
# you're using (see modules/packages/terminals.nix).
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    helix
  ];
}
