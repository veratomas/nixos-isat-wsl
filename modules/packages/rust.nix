# modules/packages/rust.nix
#
# Rust toolchain via rust-overlay (flake input, layered into `pkgs` in
# flake.nix). This gives us `pkgs.rust-bin`: a reproducible, rustup-like
# way to pin an exact toolchain + components + cross-compilation targets,
# without needing rustup itself (which fights with Nix's read-only
# store -- it wants to manage its own installation under ~/.rustup).
{ pkgs, ... }:

let
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [
      "rust-src" # standard library source -- lets rust-analyzer "go to definition" into std
      "rust-analyzer" # LSP, bundled as a toolchain component so its version always matches rustc
      "clippy" # linter
      "rustfmt" # formatter
    ];
    targets = [
      "x86_64-unknown-linux-gnu" # default target, dynamically linked against glibc
      "x86_64-unknown-linux-musl" # statically-linkable target -- e.g. for minimal container images
    ];
  };
in
{
  environment.systemPackages = [
    rustToolchain

    # Lets `cargo build` locate system libraries via .pc files (e.g. the
    # openssl below, when a crate like `openssl-sys` links against it
    # instead of vendoring/using rustls) -- most non-trivial Rust
    # projects that touch C libraries need this.
    pkgs.pkg-config
  ];

  # openssl, gcc, and glibc are shared, general-purpose dependencies used
  # by more than just Rust, so they're declared once for everyone in
  # modules/packages/dev-tools.nix instead of here.

  # --- Adding another target or component --------------------------------
  # Add more entries to the `targets` / `extensions` lists above, e.g.
  # `"wasm32-unknown-unknown"` for a WASM target, or `"llvm-tools"` for
  # coverage tooling, then rebuild.
}
