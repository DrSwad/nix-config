{ pkgs, ... }:

let
  yaml = pkgs.formats.yaml { };
in
{
  # pueue: queue shell commands, run them one at a time, inspect them later.
  home.packages = [ pkgs.pueue ];

  # NIXPKGS-PIN: keys below are pueue 4.0.4's. 4.0.0 reworked the protocol, the
  # state format and task editing, so anything written against 3.x is worth
  # rechecking whenever nixpkgs moves past 26.05.
  xdg.configFile."pueue/pueue.yml".source = yaml.generate "pueue.yml" {
    # Unix socket rather than TCP. modules/tailscale.nix marks tailscale0 a
    # trusted interface, so a TCP listener here would be reachable from every
    # device on the tailnet; a socket under the runtime dir cannot be.
    shared.use_unix_socket = true;

    client = {
      # `pueue reset` and `pueue remove` ask before throwing work away. Cheap
      # insurance on a queue holding hour-long jobs rather than second-long ones.
      show_confirmation_questions = true;

      # 4.0 rewrote editing. "toml" serialises every task being edited into a
      # single document opened in $EDITOR. The other mode, "files", writes one
      # file per property and expects an editor with a built-in file tree.
      edit_mode = "toml";
    };
  };

  # users.users.swad.linger in modules/common.nix is what starts this at boot and
  # keeps it alive after the last SSH session closes.
  systemd.user.services.pueued = {
    Unit.Description = "pueue daemon";
    Install.WantedBy = [ "default.target" ];
    Service = {
      # No -d. That forks pueued into the background, which a Type=simple unit
      # reads as the service having exited a moment after starting.
      #
      # Tasks inherit this process's environment. The user manager already
      # carries the system and per-user profiles in PATH, so nvidia-smi and the
      # rest of the toolchain resolve without help here.
      ExecStart = "${pkgs.pueue}/bin/pueued";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
