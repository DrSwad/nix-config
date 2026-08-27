{ config, ... }:

{
  services.tailscale = {
    enable = true;

    # "both" rather than "server": the client half relaxes reverse-path
    # filtering from strict to loose, without which routing this machine's
    # own traffic through a remote exit node silently fails.
    useRoutingFeatures = "both";
  };

  networking.firewall = {
    # Direct peer-to-peer connections arrive here; without it, traffic falls
    # back to relaying through DERP servers and latency suffers.
    allowedUDPPorts = [ config.services.tailscale.port ];

    # The tailnet is personal devices only, so treat it as trusted. Colleagues
    # reach this box over LAN via OpenSSH, which this line does not affect.
    trustedInterfaces = [ config.services.tailscale.interfaceName ];
  };
}
