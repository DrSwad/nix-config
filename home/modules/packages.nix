{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden-cli
    ghostty
    joplin-desktop
    qutebrowser
    rofi
    vim
    wl-clipboard
  ];

  # yazi's built-in "edit" opener runs ${EDITOR:-vi}
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };
}
