{ config, inputs, pkgs, ... }:

{
  imports = [ inputs.paseo.nixosModules.default ];

  services.paseo = {
    enable = true;

    # Two v0.10.3 packaging bugs; after bumping the tag, try without each.
    # - nix/npm-deps.hash is stale: on a hash mismatch, put the "got" value here.
    # - The install step looks for node-pty's native addon in the root
    #   node_modules, but npm places it under packages/server, so the terminal
    #   worker crashes on startup.
    package =
      (inputs.paseo.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
        npmDepsHash = "sha256-uG7EkoQMVLk5CzDEbJbR5aPxeq59x4vjF21JGatxD7k=";
      }).overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          pty=packages/server/node_modules/node-pty
          for f in $pty/build/Release/pty.node $pty/prebuilds/linux-x64/pty.node; do
            [ -e "$f" ] && install -D "$f" "$out/lib/paseo/$f"
          done
          [ -n "$(find $out/lib/paseo/$pty -name pty.node)" ]
        '';
      });

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
