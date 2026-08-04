# modules/packages/dev-tools.nix
#
# General-purpose C toolchain bits and libraries that don't belong to any
# one language module -- this is usually the file you want when "just
# add package X" doesn't obviously belong anywhere more specific.
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- compiler / C toolchain -----------------------------------------
    gcc # C/C++ compiler on PATH. Rust/Python native extensions
    # already pull a compiler in via stdenv at build time, but
    # having `gcc`/`cc` available interactively (quick `gcc -o`
    # tests, tools that shell out to `cc`) is worth it.
    glibc # the GNU C library NixOS itself is built on, listed
    # explicitly so its headers/utilities (`ldd`, `getent`, ...)
    # are guaranteed present even in a minimal profile.
    openssl # TLS library + CLI (`openssl` command) + dev headers, for
    # anything (Rust, Python, curl, ...) that links or shells
    # out to it.
    zbar # provides libzbar (used by the pyzbar Python binding, see
    # modules/packages/python.nix) plus the `zbarimg` /
    # `zbarcam` CLI tools for quick manual barcode/QR testing.

    # --- everyday CLI tools ----------------------------------------------
    unzip
    tree

    # Add more here, e.g.:
    # ripgrep
    # jq
  ];

  # --- Adding a new package, in general ----------------------------------
  # 1. Find the exact nixpkgs attribute name: https://search.nixos.org/packages
  # 2. Add it to the most relevant modules/packages/*.nix file (or here,
  #    if it's general-purpose), inside a `with pkgs; [ ... ]` list.
  # 3. Rebuild (see scripts/rebuild.sh / the README).
}
