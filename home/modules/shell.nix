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

    # Untracked: `export ATUIN_SYNC_ADDRESS=https://atuin.<domain>`.
    envExtra = "[[ -r ~/.config/atuin/private.env ]] && source ~/.config/atuin/private.env";

    # HIST_FCNTL_LOCK has no HM option: locking that survives concurrent
    # writes from tmux panes.
    initContent = "setopt HIST_FCNTL_LOCK";
  };

  # Sync server is self-hosted outside this repo; keep it at or above this client's version.
  programs.atuin = {
    enable = true;
    # Otherwise `?` on an empty prompt opens Atuin AI, a cloud service.
    flags = [ "--disable-ai" ];
    settings = {
      filter_mode_shell_up_key_binding = "directory";
      search_mode_shell_up_key_binding = "prefix";
      workspaces = true;
      enter_accept = true;
    };
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd" "cd" ];
  };
}
