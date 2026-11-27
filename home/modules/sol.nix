{ lib, osConfig, pkgs, ... }:

let
  sol = lib.findFirst (r: r.name == "sol") null osConfig.swad.remotes;

  jobName = "sol-alloc";

  # sol-alloc's own options come after these, so they win.
  # The class account and QoS stop working once ASU RC archives the class
  # account after Fall 2026: switch to the lab's account and `-q public`.
  # -C a100_80: gpu:a100 alone may land on a 40GB A100.
  allocArgs = "-A class_cse57669240fall2026 -q class -p public -c 32 --mem=80G --gres=gpu:a100:1 -C a100_80 -t 0-16";
in
{
  config = lib.mkIf (sol != null) {
    # Compute nodes: reachable only through the login node, and only while
    # one of your jobs is running on them.
    programs.ssh.settings."*.sol.rc.asu.edu" = {
      User = sol.user;
      IdentityFile = sol.identityFile;
      ProxyJump = sol.name;
      # Each job can land on a new node
      StrictHostKeyChecking = "accept-new";
    };

    home.packages = [
      # sol-alloc [-u USER] [SALLOC_OPTION...]
      (pkgs.writeShellScriptBin "sol-alloc" ''
        set -euo pipefail
        user=${sol.user}
        if [[ ''${1-} == -u ]]; then
          user=''${2:?usage: sol-alloc [-u USER] [SALLOC_OPTION...]}
          shift 2
        fi
        exec ssh "$user@${sol.name}" salloc --no-shell -J ${jobName} ${allocArgs} "$@"
      '')

      # sol-node [-u USER] [-j JOBID|JOBNAME] [COMMAND...]
      (pkgs.writeShellScriptBin "sol-node" ''
        set -euo pipefail
        usage="usage: sol-node [-u USER] [-j JOBID|JOBNAME] [COMMAND...]"
        user=${sol.user}
        filter=""
        while (( $# )); do
          case $1 in
            -u) user=''${2:?$usage}; shift 2 ;;
            -j)
              job=''${2:?$usage}
              if [[ $job =~ ^[0-9]+$ ]]; then filter="-j $job"; else filter="-n $job"; fi
              shift 2
              ;;
            *) break ;;
          esac
        done
        out=$(ssh "$user@${sol.name}" "squeue --me -h -t R -o '%N %i %j' $filter")
        mapfile -t jobs < <(printf '%s' "$out")
        if (( ''${#jobs[@]} != 1 )); then
          echo "sol-node: need exactly one running job, found ''${#jobs[@]}:" >&2
          (( ''${#jobs[@]} )) && printf '  %s\n' "''${jobs[@]}" >&2
          exit 1
        fi
        read -r nodes _ <<<"''${jobs[0]}"
        node=$(sed -E 's/\[([0-9]+)[^]]*\]/\1/; s/,.*//' <<<"$nodes")
        exec ssh -J "$user@${sol.name}" "$user@$node.sol.rc.asu.edu" "$@"
      '')

      # sol-release [-u USER] [-j JOBID|JOBNAME]
      # Defaults to sol-alloc's jobs, so other jobs need an explicit -j.
      (pkgs.writeShellScriptBin "sol-release" ''
        set -euo pipefail
        usage="usage: sol-release [-u USER] [-j JOBID|JOBNAME]"
        user=${sol.user}
        job=${jobName}
        while (( $# )); do
          case $1 in
            -u) user=''${2:?$usage}; shift 2 ;;
            -j) job=''${2:?$usage}; shift 2 ;;
            *) echo "$usage" >&2; exit 2 ;;
          esac
        done
        if [[ $job =~ ^[0-9]+$ ]]; then filter="-j $job"; else filter="-n $job"; fi
        ids=$(ssh "$user@${sol.name}" "squeue --me -h -o %i $filter")
        if [[ -z $ids ]]; then
          echo "sol-release: no job matching '$job'" >&2
          exit 1
        fi
        ssh "$user@${sol.name}" scancel $ids
        echo "sol-release: cancelled" $ids
      '')
    ];
  };
}
