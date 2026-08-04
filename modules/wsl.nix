# modules/wsl.nix
#
# WSL2 integration. The `wsl.*` options come from the NixOS-WSL flake
# input (wired up in flake.nix). NixOS-WSL already handles mounting
# WSLg's X11 socket (/tmp/.X11-unix) and Wayland socket automatically when
# `wsl.enable` is on -- you do not need to configure X11/Wayland
# yourself, and you should NOT enable services.xserver on a WSL host.
{ config, pkgs, lib, ... }:

{
  wsl = {
    enable = true;

    # The Linux user you land in when you open a WSL terminal or launch a
    # GUI app shortcut. "nixos" is just the fallback default -- each
    # developer can (and should) set their own in hosts/wsl/local.nix,
    # which scripts/bootstrap.sh will offer to create for you
    # interactively on first install. Referenced from modules/users.nix,
    # so overriding it here is all you need to do; the user account
    # follows automatically.
    #
    # Pick your value BEFORE your first rebuild if you can: NixOS-WSL
    # creates the matching home directory as part of that first build,
    # and renaming defaultUser afterwards works but needs some manual
    # home-directory cleanup (see the NixOS-WSL docs) rather than "just
    # change this and rebuild".
    defaultUser = lib.mkDefault "nixos";

    # Adds Start Menu entries for GUI apps installed in this config (VS
    # Code, etc.) so they show up and behave like normal Windows apps.
    startMenuLaunchers = true;

    # --- GUI / "window passthrough" -------------------------------------
    # This is the important option for GUI apps: it tells the system to
    # use the Windows host's GPU driver (mounted in via WSLg) for
    # OpenGL/Vulkan, instead of trying to use a native Linux GPU driver
    # that doesn't exist inside a WSL2 VM. Without this, GUI apps either
    # fail to start or silently fall back to slow, CPU-only software
    # rendering (Mesa's "llvmpipe").
    useWindowsDriver = true;

    # Docker itself now runs natively inside this NixOS distro (see
    # modules/docker.nix, `virtualisation.docker.enable`), so there's no
    # need for Docker Desktop's WSL2 integration on the Windows side. If
    # you'd rather use Docker Desktop's integration instead, disable
    # modules/docker.nix and uncomment the option below:
    # docker-desktop.enable = true;
  };

  # Want to forward an ssh-agent running on Windows (1Password, Pageant,
  # Windows' built-in OpenSSH agent, etc.) into this WSL instance instead
  # of managing keys inside Linux? NixOS-WSL has a built-in option for
  # this -- check `wsl.<TAB>` after a rebuild, or the current options at
  # https://nix-community.github.io/NixOS-WSL/options.html for the exact
  # name, since it has moved once or twice between releases.

  # Known rough edge: some GPU-heavy apps can crash instead of gracefully
  # falling back to software rendering under WSLg's Vulkan-on-DirectX12
  # translation layer ("Dozen"). If a GUI app misbehaves, check the
  # Troubleshooting section of the README -- this is usually why.
}
