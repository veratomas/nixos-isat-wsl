{
  description = "Team NixOS flake-base configuration for WSL development environments";

  inputs = {
    # Pinned to the NixOS 26.05 stable release branch. Everyone who builds
    # this flake gets the exact same package set until someone deliberately
    # runs `nix flake update` (see scripts/upgrade-os.sh) and commits the
    # resulting flake.lock. Don't change this to "nixos-unstable" for a
    # shared team config -- that trades reproducibility for freshness, which
    # is the opposite of what this repo is for.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # NixOS-WSL supplies the `wsl.*` options and glue code that make a
    # NixOS system behave correctly as a WSL2 distribution: systemd
    # support, /mnt/wslg X11 + Wayland socket wiring, Start Menu shortcuts,
    # interop with Windows PATH/clipboard, etc.
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # rust-overlay exposes `pkgs.rust-bin`, a reproducible, rustup-like way
    # to select an exact Rust toolchain + components + cross targets,
    # without needing rustup itself (which doesn't play well with Nix's
    # read-only store).
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nixos-wsl, rust-overlay, ... }@inputs:
    let
      # WSL2 is x86_64 in the overwhelming majority of cases. If your team
      # is on ARM64 Windows (Copilot+ PCs etc.), change this to
      # "aarch64-linux" -- everything else in this flake is
      # architecture-agnostic and will keep working.
      system = "x86_64-linux";
    in
    {
      # Build with:  sudo nixos-rebuild switch --flake .#wsl
      # ("wsl" here is the attribute name below, not a fixed keyword --
      # rename it if you prefer, but update the scripts/ and README to match.)
      nixosConfigurations.wsl = nixpkgs.lib.nixosSystem {
        inherit system;

        # Makes flake inputs (nixos-wsl, rust-overlay, ...) available as
        # `inputs` inside every module below, in case a module ever needs
        # to reach for one directly.
        specialArgs = { inherit inputs; };

        modules = [
          nixos-wsl.nixosModules.default

          # Layer the Rust toolchain overlay into `pkgs` for the whole
          # system, so any module can just write `pkgs.rust-bin...`.
          { nixpkgs.overlays = [ rust-overlay.overlays.default ]; }

          ./hosts/wsl
        ];
      };

      # Lets you run `nix fmt` at the repo root to auto-format every .nix
      # file using the official Nix formatter (nixfmt, RFC 166).
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
