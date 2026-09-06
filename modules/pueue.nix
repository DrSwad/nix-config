{ pkgs, ... }:

let
  # Keys below are pueue 4.0.4's. 4.0.0 reworked the protocol, the state
  # format and task editing, so anything written against 3.x is worth
  # rechecking whenever nixpkgs moves past 26.05.
  configFile = pkgs.writeText "pueue.yml" ''
    shared:
      # Unix socket rather than TCP. modules/tailscale.nix marks tailscale0 a
      # trusted interface, so a TCP listener here would be reachable from every
      # device on the tailnet; a socket under the runtime dir cannot be.
      use_unix_socket: true

    client:
      # `pueue reset` and `pueue remove` ask before throwing work away. Cheap
      # insurance on a queue holding hour-long jobs rather than second-long ones.
      show_confirmation_questions: true

      # 4.0 rewrote editing. "toml" serialises every task being edited into a
      # single document opened in $EDITOR (vim, per modules/common.nix). The
      # other mode, "files", writes one file per property and expects an editor
      # with a built-in file tree.
      edit_mode: toml
  '';
in
{
  # pueue: queue shell commands, run them one at a time, inspect them later.
  environment.systemPackages = [ pkgs.pueue ];

  # pueue stopped reading /etc/pueue/ in 2.0.0, so neither half finds this file
  # on its own. The client is pointed at it by the variable below; the daemon
  # gets the same store path directly, so the two cannot drift onto different
  # configs. environment.variables lands in /etc/profile, which interactive
  # shells read and the lingering user manager never does — hence --config
  # rather than relying on the variable reaching pueued.
  #
  # A shell that predates this variable, including one you re-exec'd into since
  # that keeps the old environment, makes the client fail with "Couldn't find a
  # configuration file. Did you start the daemon yet?" while pueued is in fact
  # running fine. Only the daemon may write a default config and ours never will,
  # having been given --config, so the client has no fallback. Log in afresh
  # rather than believing the error.
  environment.etc."pueue/pueue.yml".source = configFile;
  environment.variables.PUEUE_CONFIG_PATH = "/etc/pueue/pueue.yml";

  # A user service, not a system one: the socket, the logs, and the tasks
  # themselves all belong to a single user. users.users.swad.linger in
  # modules/common.nix is what starts this at boot and keeps it alive after the
  # last SSH session closes, the same property that keeps tmux reattachable.
  #
  # nixos-rebuild leaves user units to the user manager. A first install needs
  # `systemctl --user daemon-reload` then `systemctl --user start pueued` once;
  # a later config edit needs `systemctl --user restart pueued`. Neither is
  # needed across a reboot, which is what linger buys.
  systemd.user.services.pueued = {
    description = "pueue daemon";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      # No -d. That forks pueued into the background, which a Type=simple unit
      # reads as the service having exited a moment after starting.
      #
      # Tasks inherit this process's environment. The user manager already
      # carries the system and per-user profiles in PATH, so nvidia-smi and the
      # rest of the toolchain resolve without help here.
      ExecStart = "${pkgs.pueue}/bin/pueued --config ${configFile}";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };
}
