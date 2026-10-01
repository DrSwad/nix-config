{ lib, ... }:

{
  options.swad.hermes.bindHost = lib.mkOption {
    type = lib.types.str;
    default = "127.0.0.1";
    example = "my-box.tailnet-name.ts.net";
    description = ''
      Address the hermes dashboard binds to, and the only Host header it
      accepts — clients must use this exact name.

      Host-scoped because it names this machine. A tailnet MagicDNS name makes
      the dashboard reachable from every device on the tailnet and nowhere
      else, given modules/tailscale.nix trusts that interface. The loopback
      default keeps it local, and also skips the auth gate that any other
      address requires.
    '';
  };
}
