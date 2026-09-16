{ lib, osConfig, pkgs, ... }:

let
  remotes = osConfig.swad.remotes;

  # One startup tab per remote, appended after the local "." tab.
  # Every remote is registered as a VFS service, but only always-on ones
  # earn a startup tab — see openTab in modules/remotes.nix.
  remoteTabs = lib.concatMapStrings (r: " sftp://${r.name}") (
    lib.filter (r: r.openTab) remotes
  );
in
{
  programs.yazi = {
    enable = true;

    # The wrapper below replaces HM's `yy`, which has no way to pass startup tabs.
    enableZshIntegration = false;

    # Packaged rather than installed with `ya pkg`, which would write into
    # ~/.config/yazi and put the plugin's version outside this repo.
    plugins = { inherit (pkgs.yaziPlugins) git; };

    initLua = ''
      -- `order` places the git sign among the linemode's other children.
      require("git"):setup { order = 1500 }
    '';

    settings = {
      # Default sorting is alphabetical, which puts file10 ahead of file2.
      mgr.sort_by = "natural";

      # The fetcher runs `git status` once per directory and hands each entry a
      # status. Two rules because files (`*`) and directories (`*/`) are matched
      # separately. `group`, not the `id` older docs show: renamed after Yazi
      # 26.1.22. local:// scopes this to real files, so the sftp:// startup tabs
      # don't each spawn a git process against a path git can't read.
      plugin.prepend_fetchers = [
        { url = "local://*"; run = "git"; group = "git"; }
        { url = "local://*/"; run = "git"; group = "git"; }
      ];
    };

    # Letters rather than the plugin's default Nerd Font glyphs, so the column
    # reads like `git status --short`. An empty sign is special-cased: the
    # linemode child returns nothing at all, so clean files cost no width.
    #
    # NIXPKGS-PIN: These are the eight codes yaziPlugins.git 2026-05-09 reads. Later
    # revs split modified into staged/unstaged; an unread key is not an error, so
    # after bumping nixpkgs check the defaults table against
    # $(nix eval --raw .#nixosConfigurations.swad-lab-pc.pkgs.yaziPlugins.git)/main.lua
    theme.git = {
      unknown_sign = "";
      clean_sign = "";
      ignored_sign = "";
      untracked_sign = "?";
      modified_sign = "M";
      added_sign = "A";
      deleted_sign = "D";
      updated_sign = "U";

      # "updated" is git's unmerged state, and its default yellow is the same
      # yellow as a modified file. A conflict should stand out.
      updated = { fg = "red"; bold = true; };
    };

    # NIXPKGS-PIN: yazi 26.5.6 spells these [services.<name>] with an explicit type
    # field. The rename to [sftp.<name>] landed after this release.
    #
    # Authenticates with the key file directly rather than the agent, which is
    # the default. The key has no passphrase, so this drops a dependency on
    # $SSH_AUTH_SOCK being populated.
    vfs.services = lib.listToAttrs (
      map (
        r:
        lib.nameValuePair r.name {
          type = "sftp";
          inherit (r) host user port;
          key_file = r.identityFile;
        }
      ) remotes
    );
  };

  programs.zsh.initContent = ''
    # A child process can't change its parent's directory, so following yazi on
    # exit needs a wrapper: yazi writes its final cwd to a file and the function
    # cd's there afterwards.
    yazi() {
      local tmp cwd
      tmp="$(mktemp -t yazi-cwd.XXXXXX)"
      # Bare `yazi` gets the full layout; `yazi <path>` stays local and opens no
      # SSH connections, which matters off the lab network.
      if [ $# -eq 0 ]; then
        command yazi .${remoteTabs} --cwd-file="$tmp"
      else
        command yazi "$@" --cwd-file="$tmp"
      fi
      IFS= read -r -d "" cwd < "$tmp"
      # -d is what guards the remote case: quitting from an sftp:// tab writes a
      # URL, not a path, and cd would fail on every such exit.
      [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && cd -- "$cwd"
      rm -f -- "$tmp"
    }
  '';
}
