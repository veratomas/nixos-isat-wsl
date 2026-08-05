# modules/packages/services.nix
#
# Background services: a local PostgreSQL for development databases.
{ config, pkgs, lib, ... }:

{
  # ---------------------------------------------------------------------
  # PostgreSQL
  # ---------------------------------------------------------------------
  services.postgresql = {
    enable = true;

    # Pin a major version so `pg_dump`/`pg_restore` compatibility and the
    # on-disk format stay identical across every team member's machine.
    # Bump this deliberately (and call it out in a PR) rather than
    # letting it silently float whenever nixpkgs updates its default.
    package = pkgs.postgresql_17;

    enableTCPIP = true; # allow localhost:5432 connections (not just Unix sockets) -- needed by most GUI DB clients

    # Trust local (same-machine) connections without a password. This
    # Postgres isn't reachable outside WSL's own network namespace by
    # default, so this is a reasonable convenience default for local
    # development. Tighten this (e.g. require scram-sha-256, set real
    # passwords via ensureUsers below) if your team's threat model calls
    # for it -- e.g. if you flip on WSL "mirrored" networking mode, which
    # can make WSL services reachable from other devices on your LAN.
    authentication = lib.mkForce ''
      local all all trust
      host  all all 127.0.0.1/32 trust
      host  all all ::1/128      trust
    '';

    # Declaratively create a role + database per project instead of
    # everyone running `createuser`/`createdb` by hand. Example -- edit
    # to match your project(s) and uncomment:
    ensureDatabases = [ "sisar" ];
    # ensureUsers = [
    #   {
    #     name = "myapp";
    #     ensureDBOwnership = true; # requires "myapp" to also be listed in ensureDatabases above
    #   }
    # ];
  };
}
