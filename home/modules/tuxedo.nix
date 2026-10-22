{ config, pkgs, ... }:

let
  todoDir = "${config.home.homeDirectory}/todo";
in
{
  # NIXPKGS-PIN: 26.05 doesn't package tuxedo. Move to pkgs.tuxedo once stable
  # carries a release at least as new as unstable's.
  home.packages = [ pkgs.unstable.tuxedo ];

  home.sessionVariables = {
    TODO_DIR = todoDir;
    # Read by o/O (tuxedo >= 2026.7.1). A notes_dir key in tuxedo's own
    # config.toml outranks this.
    NOTES_DIR = "${todoDir}/notes";
    # The binary is immutable, so the status bar's upgrade hint can't be acted on.
    TUXEDO_NO_UPDATE_CHECK = "1";
  };
}
