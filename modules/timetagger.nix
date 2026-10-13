{ pkgs, ... }:

{
  systemd.services.timetagger = {
    description = "TimeTagger time tracker";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    environment = {
      # Every interface with the port left closed in the firewall, as in
      # modules/paseo.nix: loopback and tailscale0 only, not the LAN.
      TIMETAGGER_BIND = "0.0.0.0:8082";
      TIMETAGGER_DATADIR = "/var/lib/timetagger";
      TIMETAGGER_APP_REDIRECT = "true";
    };

    serviceConfig = {
      # Not pkgs.timetagger: its wrapper hardcodes TIMETAGGER_BIND, which
      # outranks the environment above.
      ExecStart = "${pkgs.python3.withPackages (p: [ p.timetagger ])}/bin/python -m timetagger";
      DynamicUser = true;
      StateDirectory = "timetagger";
      Restart = "on-failure";
      # TIMETAGGER_CREDENTIALS='swad:<bcrypt hash>', untracked and 0600.
      EnvironmentFile = "/home/swad/.config/timetagger/secrets.env";
    };
  };
}
