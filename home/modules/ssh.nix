{ lib, osConfig, ... }:

{
  programs.ssh = {
    enable = true;

    # Suppresses HM's legacy `Host *` block (ForwardAgent no, ControlMaster no,
    # …), which is slated for removal upstream. OpenSSH's own defaults apply.
    enableDefaultConfig = false;

    # NIXPKGS-PIN: `settings` with upstream directive names; the older
    # `matchBlocks` spelling is deprecated but still present in HM 26.05.
    settings = lib.listToAttrs (
      map (
        r:
        lib.nameValuePair r.name {
          HostName = r.host;
          User = r.user;
          Port = r.port;
          IdentityFile = r.identityFile;
        }
      ) osConfig.swad.remotes
    );
  };
}
