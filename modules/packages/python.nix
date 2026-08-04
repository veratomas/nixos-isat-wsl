# modules/packages/python.nix
#
# A single, declarative Python environment shared by every project on
# this machine. If a project needs a package that isn't listed below,
# add it to the `pythonPackages` list (search exact names at
# https://search.nixos.org/packages) and rebuild -- no venv/pip juggling
# needed for anything already packaged in nixpkgs.
{ pkgs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      python-telegram-bot
      python-dotenv
      httpx
      pillow

      # NOTE on pyzbar: nixpkgs patches this package at build time to
      # point straight at the Nix store's libzbar.so, so -- unlike a
      # plain `pip install pyzbar` on most distros -- it finds the zbar
      # shared library correctly with zero extra setup. That patch only
      # works because `zbar` is also installed system-wide (see
      # modules/packages/dev-tools.nix); don't remove that without also
      # removing this.
      pyzbar
    ]
  );
in
{
  environment.systemPackages = [
    pythonEnv

    # --- LSP + formatter/linter -------------------------------------
    pkgs.pyright # language server: types, go-to-definition, hover, etc.
    pkgs.ruff # extremely fast linter + formatter (covers what
    # black/isort/flake8 would separately); also speaks
    # the LSP protocol if your editor prefers it over
    # pyright for diagnostics
  ];

  # --- Adding a new library ---------------------------------------------
  # Add it to the list above, e.g.:
  #   ps: with ps; [ python-telegram-bot python-dotenv httpx pillow pyzbar
  #                  requests numpy ];
  #
  # Prefer per-project virtualenvs instead of one shared system Python?
  # `nix shell nixpkgs#python3` + a project-local `pip install -r
  # requirements.txt` still works fine on top of this -- the environment
  # above covers the common/shared case, it isn't the only way to use
  # Python here.
}
