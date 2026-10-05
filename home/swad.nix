{ ... }:

{
  imports = [
    ./modules/claude-code.nix
    ./modules/clipboard.nix
    ./modules/gh.nix
    ./modules/git.nix
    ./modules/manim.nix
    ./modules/neovim
    ./modules/niri.nix
    ./modules/packages.nix
    ./modules/pi.nix
    ./modules/pueue.nix
    ./modules/shell.nix
    ./modules/ssh.nix
    ./modules/theme.nix
    ./modules/tmux.nix
    ./modules/typst.nix
    ./modules/yazi.nix
  ];

  # Pins HM's stateful defaults. Set once, never bumped.
  home.stateVersion = "26.05";

  # HM restarts user units whose unit file changed. pueue.yml is not part of
  # pueued's unit, so daemon-side settings there need a manual
  # `systemctl --user restart pueued`, which kills running tasks.
  systemd.user.startServices = "sd-switch";
}
