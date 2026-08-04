# modules/packages/terminals.nix
#
# GUI terminal emulators. Like the GUI editor(s) in
# modules/packages/editors.nix, these are native Linux builds forwarded
# to your Windows desktop by WSLg -- GPU accelerated thanks to
# modules/wsl.nix's `wsl.useWindowsDriver = true`. The default login
# shell inside them is Nushell (see modules/shell.nix).
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    kitty
    kdePackages.konsole
  ];
}
