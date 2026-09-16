{ ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    # HIST_FCNTL_LOCK has no HM option: locking that survives concurrent
    # writes from tmux panes.
    initContent = "setopt HIST_FCNTL_LOCK";
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
  };
}
