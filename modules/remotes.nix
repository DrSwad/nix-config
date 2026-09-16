{ lib, ... }:

{
  options.swad.remotes = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          description = ''
            Alias used both as ssh's Host and as yazi's VFS service name.
            Kebab-case, 20 characters or fewer — yazi rejects longer names.
          '';
        };
        host = lib.mkOption {
          type = lib.types.str;
          description = "Address actually dialled, i.e. ssh's HostName.";
        };
        user = lib.mkOption {
          type = lib.types.str;
          description = "Account to log in as.";
        };
        port = lib.mkOption {
          type = lib.types.port;
          default = 22;
          description = "Port sshd listens on.";
        };
        identityFile = lib.mkOption {
          type = lib.types.str;
          default = "~/.ssh/id_ed25519";
          description = ''
            Private key offered to this host. A path, never key material, so
            it stays safe in a public repo. Both ssh and yazi expand the tilde
            themselves, so leave it unexpanded — a /home/swad path here would
            be wrong for any other user on the machine.
          '';
        };
        openTab = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Whether bare `yazi` opens a startup tab for this machine.

            False for hosts that are often asleep or off-network: a tab costs
            a connection attempt on every launch, which an always-on server
            absorbs and a laptop does not. The VFS service is still
            registered either way, so `cd sftp://name` inside yazi keeps
            working on demand.
          '';
        };
      };
    });
    default = [ ];
    example = [
      {
        name = "some-box";
        host = "10.0.0.2";
        user = "me";
      }
    ];
    description = ''
      Remote machines this host talks to.

      A list rather than an attrset because order is meaningful: yazi opens
      one startup tab per entry, in the order given, and attrset keys would
      instead be sorted alphabetically.

      Read twice — the ssh_config blocks below, and yazi's vfs.toml over in
      modules/yazi.nix — so each machine is described once and the two can't
      drift apart.

      Host-scoped because these are site-specific addresses. A host that
      isn't on that network leaves this empty and gets no aliases and no
      remote tabs, rather than three connections that always fail.
    '';
  };
}
