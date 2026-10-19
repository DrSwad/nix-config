{ config, inputs, pkgs, ... }:

{
  imports = [ inputs.paseo.nixosModules.default ];

  services.paseo = {
    enable = true;

    # NIXPKGS-PIN: from unstable because the paseo flake input's own package
    # builds from source. Keep the client apps on the version this prints:
    #   nix eval --raw .#nixosConfigurations.swad-lab-pc.config.services.paseo.package.version
    package = pkgs.unstable.paseo;

    # The login user, so agents see ~/.pi, the repos and the user profile's PATH.
    user = "swad";
    group = "users";

    # Every interface, with the port left closed in the firewall: reachable on
    # loopback, which Paseo's SSH transport dials, and on tailscale0, which
    # modules/tailscale.nix trusts. Not from the LAN.
    listenAddress = "0.0.0.0";

    # IPs and localhost always pass the Host check; names must be listed.
    hostnames = [ config.networking.hostName ".ts.net" ];

    # Clients connect directly over the tailnet.
    relay.enable = false;

    environment = {
      PASEO_WEB_UI_ENABLED = "true";

      # HM's tmux module keeps the socket under the runtime dir, which only
      # login shells learn about. Without this, agents following
      # home/modules/pi-rules.md start a second server under /tmp. 1000 is
      # swad's uid; linger keeps the directory present from boot.
      TMUX_TMPDIR = "/run/user/1000";
    };
  };

  # PASEO_PASSWORD=…, untracked and 0600. Plaintext; the daemon hashes it at startup.
  systemd.services.paseo.serviceConfig.EnvironmentFile = "/home/swad/.config/paseo/secrets.env";
}
