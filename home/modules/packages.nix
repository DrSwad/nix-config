{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden-cli
    joplin-desktop
    localsend
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
