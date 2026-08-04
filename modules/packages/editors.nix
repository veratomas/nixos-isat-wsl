# modules/packages/editors.nix
#
# GUI editors. Installed as a native Linux app and forwarded to your
# Windows desktop by WSLg -- this is the "window passthrough" that
# modules/wsl.nix's `wsl.useWindowsDriver = true` makes fast (GPU
# accelerated) instead of software-rendered.
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    vscode
  ];

  # VS Code's Remote - WSL extension (ms-vscode-remote.remote-wsl),
  # installed in a Windows-side VS Code, is generally the most robust way
  # to work with this machine: running `code .` from inside this NixOS
  # shell opens a window on Windows while everything else (terminal,
  # extensions, language servers) runs here. The package above is still
  # installed so the Linux GUI build works fine too (or if you're
  # connecting in over RDP/a non-GPU-accelerated path anyway).
}
