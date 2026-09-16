{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    prefix = "M-Space";
    keyMode = "vi";

    # prefix + hjkl moves between panes, prefix + HJKL resizes them.
    customPaneNavigationAndResize = true;

    # Defaults to "screen", which costs truecolor and italics.
    terminal = "tmux-256color";

    # How long tmux waits after Esc to see whether an escape sequence follows.
    # The 500ms default is felt as a delay leaving insert mode in vim.
    escapeTime = 10;

    extraConfig = ''
      # v defaults to rectangle-toggle rather than starting a selection.
      bind -T copy-mode-vi v   send -X begin-selection
      bind -T copy-mode-vi V   send -X select-line
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y   send -X copy-pipe-and-cancel '${pkgs.wl-clipboard}/bin/wl-copy'

      # copy-pipe jobs run with the *session* environment, and tmux only
      # refreshes the variables named here when a client attaches. Without
      # WAYLAND_DISPLAY, wl-copy fails inside a server that outlived a
      # compositor restart.
      set -ga update-environment WAYLAND_DISPLAY
    '';
  };
}
