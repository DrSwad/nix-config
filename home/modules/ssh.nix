{ lib, osConfig, pkgs, ... }:

let
  sol = lib.findFirst (r: r.name == "sol") null osConfig.swad.remotes;
in
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
    } // lib.optionalAttrs (sol != null) {
      # Sol compute nodes: reachable only through the login node, and only
      # while one of your jobs is running on them.
      "*.sol.rc.asu.edu" = {
        User = sol.user;
        IdentityFile = sol.identityFile;
        ProxyJump = sol.name;
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
  ] ++ lib.optional (sol != null) (
    # sol-node [-j JOBID|JOBNAME] [COMMAND...]
    pkgs.writeShellScriptBin "sol-node" ''
      set -euo pipefail
      filter=""
      if [[ ''${1-} == -j ]]; then
        job=''${2:?usage: sol-node [-j JOBID|JOBNAME] [COMMAND...]}
        if [[ $job =~ ^[0-9]+$ ]]; then filter="-j $job"; else filter="-n $job"; fi
        shift 2
      fi
      out=$(ssh ${sol.name} "squeue --me -h -t R -o '%N %i %j' $filter")
      mapfile -t jobs < <(printf '%s' "$out")
      if (( ''${#jobs[@]} != 1 )); then
        echo "sol-node: need exactly one running job, found ''${#jobs[@]}:" >&2
        (( ''${#jobs[@]} )) && printf '  %s\n' "''${jobs[@]}" >&2
        exit 1
      fi
      read -r nodes _ <<<"''${jobs[0]}"
      node=$(sed -E 's/\[([0-9]+)[^]]*\]/\1/; s/,.*//' <<<"$nodes")
      exec ssh "$node.sol.rc.asu.edu" "$@"
    ''
  );
}
