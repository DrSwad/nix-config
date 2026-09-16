{ lib, pkgs, ... }:

{
  options.swad.niri.outputs = lib.mkOption {
    type = lib.types.lines;
    default = "";
    example = ''
      output "DP-1" {
        position x=0 y=0
      }
    '';
    description = ''
      Per-host `output` blocks, spliced into the top of every user's
      ~/.config/niri/config.kdl by home/modules/niri.nix. Host-scoped because
      it names physical monitors.

      Outputs match on connector name or on "make model serial" as printed by
      `niri msg outputs`. Prefer the latter for identical panels: connector
      names follow the cable, not the monitor.

      Empty means niri auto-places outputs, sorting by connector name and
      laying them out left to right.
    '';
  };

  config = {
    programs.niri.enable = true;
    systemd.user.services.niri.enableDefaultPath = false;

    services.greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };

    # swaylock authenticates via PAM, and PAM denies any service with no
    # /etc/pam.d entry. Without this the correct password is rejected with
    # "pam_authenticate failed: invalid credentials", and since the locker is
    # already covering the screen, the only way out is a TTY.
    security.pam.services.swaylock = { };
  };
}
