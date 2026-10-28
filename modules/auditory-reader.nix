{ inputs, ... }:
{
  imports = [ inputs.auditory-reader.nixosModules.default ];

  services.auditory-reader = {
    enable = true;
    user = "swad";                         # owns the library folder
    tailscaleServe.enable = true;          # https://<host>.<tailnet>.ts.net
  };
}
