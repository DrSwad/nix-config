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
      bind -T copy-mode-vi y   send -X copy-pipe-and-cancel wl-copy-session

      # A yank also reaches the attached terminal's clipboard via OSC 52,
      # which is how it gets to a remote machine.
      # NIXPKGS-PIN: mosh 1.4.0 drops the sequence unless it names the
      # clipboard ("c"), a field tmux leaves empty. %p1%.0s consumes that
      # parameter at zero width; leaving it out makes tmux >= 3.4 send nothing.
      set -as terminal-overrides ',*:Ms=\E]52;c%p1%.0s;%p2%s\007'
    '';
  };
}
