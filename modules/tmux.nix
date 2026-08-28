{ ... }:

{
  programs.tmux = {
    enable = true;

    keyMode = "vi";

    # prefix + hjkl moves between panes, prefix + HJKL resizes them.
    customPaneNavigationAndResize = true;

    # This option defaults to "screen", which costs truecolor and italics.
    terminal = "tmux-256color";

    # How long tmux waits after Esc to see whether an escape sequence follows.
    # The 500ms default is felt as a delay leaving insert mode in vim.
    escapeTime = 10;

    extraConfig = ''
      # programs.tmux.shortcut can't express this — it hardcodes "C-" ahead of
      # whatever it's given. extraConfig is appended last, so this wins.
      set -g prefix M-Space

      # v defaults to rectangle-toggle rather than starting a selection.
      bind -T copy-mode-vi v   send -X begin-selection
      bind -T copy-mode-vi V   send -X select-line
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y   send -X copy-selection-and-cancel

      # Copies leave over OSC 52, so they reach the clipboard of whichever
      # machine you're sitting at, ssh included, with no wl-clipboard needed.
      # terminal-features, not terminal-overrides: the latter sets the Ms
      # capability string without the flag tmux gates emission on, which looks
      # correct in `tmux info` while silently sending nothing.
      set -s set-clipboard on
      set -as terminal-features ',xterm-ghostty:clipboard'
    '';
  };
}
