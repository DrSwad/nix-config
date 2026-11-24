{ lib, osConfig, pkgs, ... }:

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
    ) // {
      # DCSS console server; not in swad.remotes, which would also register it
      # with yazi as an sftp service. cao_key is the servers' shared login key,
      # kept untracked:
      #   curl -o ~/.ssh/cao_key http://crawl.akrasiac.org/cao_key && chmod 600 ~/.ssh/cao_key
      crg = {
        HostName = "crawl.roguelikes.gg";
        User = "crawl";
        Port = 222;
        IdentityFile = "~/.ssh/cao_key";
        IdentitiesOnly = "yes";
      };
    };
  };

  # CRG's sshd drops DGLAUTH, so dgamelaunch's own autologin can't be used;
  # the prompts are answered instead. ~/.ssh/crg_auth (untracked, 0600) holds
  # the username on line 1 and the password on line 2.
  home.packages = [
    (pkgs.writeScriptBin "crg" ''
      #!${pkgs.expect}/bin/expect -f
      set f [open $env(HOME)/.ssh/crg_auth]
      lassign [split [read -nonewline $f] "\n"] user pass
      close $f

      set timeout 15
      proc step {pat reply} {
        expect {
          -nocase $pat { send -- $reply }
          timeout { interact; exit }
          eof { exit 1 }
        }
      }

      spawn -noecho ssh crg
      trap {
        stty rows [stty rows] columns [stty columns] < $spawn_out(slave,name)
      } WINCH
      step "login" "l"
      step "enter your username" "$user\r"
      step "enter your password" "$pass\r"
      interact
    '')
  ];
}
