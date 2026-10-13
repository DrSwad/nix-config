{ lib, osConfig, pkgs, ... }:

let
  # Server is host-scoped in modules/timetagger.nix.
  port = lib.last (lib.splitString ":" osConfig.systemd.services.timetagger.environment.TIMETAGGER_BIND);

  goal = pkgs.writeScriptBin "goal" (
    builtins.replaceStrings [ "@python@" "@port@" ] [ pkgs.python3.interpreter port ] (builtins.readFile ./goal.py)
  );

  overlay = pkgs.writeTextDir "shell.qml" (
    builtins.replaceStrings [ "@goal@" ] [ "${goal}/bin/goal" ] (builtins.readFile ./shell.qml)
  );
in
{
  home.packages = [ goal ];

  programs.quickshell = {
    enable = true;
    configs.goal = overlay;
    activeConfig = "goal";
    systemd.enable = true;
  };

  systemd.user.services.quickshell.Unit = {
    # Stop with niri rather than crash-loop against a dead Wayland socket.
    PartOf = [ "graphical-session.target" ];
    # The unit file doesn't change when only the QML does, so sd-switch
    # wouldn't restart it otherwise.
    X-Restart-Triggers = [ "${overlay}" ];
  };
}
