{ ... }:

{
  programs.zsh = {
    enable = true;

    # zsh-autosuggestions: greys out the best match from history as you type.
    # Right-arrow or End accepts the whole thing, Alt+F accepts one word.
    autosuggestions.enable = true;

    # Commands turn green/red as you type them — an unknown command or an
    # unclosed quote is visible before you hit Return. The module handles the
    # source ordering this plugin is fussy about.
    syntaxHighlighting.enable = true;

    # On by default with programs.zsh.enable; stated explicitly because the
    # suggestions are much less useful without completion to fall back on.
    enableCompletion = true;

    # NixOS defaults to 2000 lines. Autosuggestions are only as good as the
    # history behind them, and this file costs kilobytes.
    histSize = 100000;

    # Replaces the NixOS default list rather than extending it, so the two
    # defaults worth keeping (HIST_IGNORE_DUPS, HIST_FCNTL_LOCK) are repeated.
    setOptions = [
      "HIST_IGNORE_DUPS"   # a command identical to the previous one isn't recorded
      "HIST_IGNORE_SPACE"  # a leading space keeps a command out of history entirely
      "HIST_FCNTL_LOCK"    # locking that survives concurrent writes from tmux panes
      "SHARE_HISTORY"      # panes see each other's commands live; swap for
                           # INC_APPEND_HISTORY if cross-pane bleed annoys you
    ];
  };

  # The frecency database lives in ~/.local/share/zoxide, outside this repo,
  # so it starts empty and gets useful over the first few days of use.
  programs.zoxide = {
    enable = true;

    # Takes over cd itself: `cd conf` jumps to the most-used matching
    # directory, `cdi` opens a picker. Literal paths (cd .., cd ./foo, cd -)
    # still behave normally — the frecency lookup is only a fallback for
    # arguments that aren't a real path.
    flags = [ "--cmd" "cd" ];
  };
}
