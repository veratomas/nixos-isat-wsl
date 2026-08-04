# modules/git.nix
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.git ];

  # System-wide, team-shared git defaults. Deliberately does NOT set
  # user.name / user.email here -- personal identity shouldn't live in a
  # config file that's pushed to a shared GitHub repo. Each developer sets
  # their own once, after their first rebuild:
  #
  #   git config --global user.name  "Your Name"
  #   git config --global user.email "you@example.com"
  #
  # (If you'd rather have this declarative too, see the comment at the
  # bottom of this file.)
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;

      # Avoids spurious "detected dubious ownership" errors, which show up
      # a lot on WSL when working across the Windows/Linux filesystem
      # boundary (e.g. a repo under /mnt/c) or after `sudo`-ing into a
      # directory.
      safe.directory = [ "*" ];

      # Remembers HTTPS credentials (e.g. a GitHub PAT) for 12 hours after
      # you enter them once, instead of asking every single push/pull.
      # Swap "cache" for "store" to persist across reboots too -- but note
      # that writes the token to disk in plain text.
      credential.helper = "cache --timeout=43200";
    };
  };

  # --- Adding a new tool here ------------------------------------------
  # This is a reasonable place for small, git-adjacent CLI tools, e.g.:
  # environment.systemPackages = [ pkgs.git pkgs.gh pkgs.git-lfs ];

  # --- Fully declarative git identity (optional) ------------------------
  # If your team *does* want identity managed by Nix (e.g. every machine
  # should use a shared "bot" identity, or you're fine with names/emails
  # being visible in a private repo), set it per-machine in
  # hosts/wsl/local.nix instead of here -- see modules/secrets.nix:
  #   programs.git.config = { user.name = "..."; user.email = "..."; };
}
