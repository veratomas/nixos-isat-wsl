# modules/docker.nix
#
# Docker, running natively inside this NixOS/WSL2 distro (as opposed to
# relying on Docker Desktop's WSL2 integration on the Windows side). This
# gives you a normal `docker` CLI + daemon with no extra Windows-side
# install required.
{ pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;

    # Start the daemon on boot rather than only on first `docker ...`
    # invocation -- avoids the "Cannot connect to the Docker daemon"
    # surprise on a fresh WSL2 launch.
    enableOnBoot = true;

    # Periodically prune dangling images/containers/build cache so the
    # Nix/WSL virtual disk doesn't grow forever, same rationale as the
    # Nix store `gc` settings in modules/core.nix.
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # docker-compose / the `docker compose` CLI plugin, plus buildx.
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # The default user needs to be in the "docker" group to run `docker`
  # without sudo -- see modules/users.nix.
}
