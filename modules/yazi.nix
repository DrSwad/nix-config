{ config, lib, ... }:

let
  remotes = config.swad.remotes;

  # yazi 26.5.6 spells these [services.<name>] with an explicit type field.
  # The rename to [sftp.<name>] landed after this release, so this mapping
  # needs rewriting whenever nixpkgs moves past 26.05.
  services = lib.listToAttrs (
    map (
      r:
      lib.nameValuePair r.name {
        type = "sftp";
        inherit (r) host user port;
        key_file = r.identityFile;
      }
    ) remotes
  );

  # One startup tab per remote, appended after the local "." tab.
  # Every remote is registered as a VFS service, but only always-on ones
  # earn a startup tab — see openTab in modules/remotes.nix.
  remoteTabs = lib.concatMapStrings (r: " sftp://${r.name}") (
    lib.filter (r: r.openTab) remotes
  );
in
{
  config = {
    programs.yazi = {
      enable = true;

      settings = {
        # Default sorting is alphabetical, which puts file10 ahead of file2.
        yazi.mgr.sort_by = "natural";

        # Authenticates with the key file directly rather than the agent,
        # which is the default. The key has no passphrase, so this drops a
        # dependency on $SSH_AUTH_SOCK being populated.
        vfs.services = services;
      };
    };

    # Lives here rather than in shell.nix because it exists only to serve
    # yazi. interactiveShellInit merges across modules, so both files can
    # contribute to /etc/zshrc without conflicting.
    programs.zsh.interactiveShellInit = ''
      # A child process can't change its parent's directory, so following
      # yazi on exit needs a wrapper: yazi writes its final cwd to a file and
      # the function cd's there afterwards.
      yazi() {
        local tmp cwd
        tmp="$(mktemp -t yazi-cwd.XXXXXX)"
        # Bare `yazi` gets the full layout; `yazi <path>` stays local and
        # opens no SSH connections, which matters off the lab network.
        if [ $# -eq 0 ]; then
          command yazi .${remoteTabs} --cwd-file="$tmp"
        else
          command yazi "$@" --cwd-file="$tmp"
        fi
        IFS= read -r -d "" cwd < "$tmp"
        # -d is what guards the remote case: quitting from an sftp:// tab
        # writes a URL, not a path, and cd would fail on every such exit.
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && cd -- "$cwd"
        rm -f -- "$tmp"
      }
    '';
  };
}
