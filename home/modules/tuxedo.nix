{ config, pkgs, ... }:

{
  # NIXPKGS-PIN: 26.05 doesn't package tuxedo. Move to pkgs.tuxedo once stable
  # carries a release at least as new as unstable's.
  home.packages = [ pkgs.unstable.tuxedo ];

  home.sessionVariables = {
    TODO_DIR = "${config.home.homeDirectory}/todo";
    # The binary is immutable, so the status bar's upgrade hint can't be acted on.
    TUXEDO_NO_UPDATE_CHECK = "1";
  };
}
