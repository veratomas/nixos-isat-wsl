# modules/packages/nix-tooling.nix
#
# Tooling for editing *this repo* (and any other Nix code). Kept separate
# from dev-tools.nix so it's an obvious place to look when someone asks
# "why isn't my editor doing anything smart with .nix files?".
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nixd # language server: hover docs, go-to-definition, NixOS option completion
    nixfmt # the official Nix formatter (RFC 166) -- point your editor's
    # "format on save" at this for individual files. The whole
    # repo can also be formatted at once with `nix fmt` at the
    # repo root (see the `formatter` output in flake.nix, which
    # uses the related `nixfmt-tree` package).

    # A couple of teams like these extra linters; uncomment if useful:
    # statix  # catches common Nix anti-patterns
    # deadnix # finds dead/unused code in .nix files
  ];
}
