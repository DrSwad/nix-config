{ ... }:

{
  imports = [
    ./modules/git.nix
    ./modules/niri.nix
    ./modules/packages.nix
    ./modules/pueue.nix
    ./modules/shell.nix
    ./modules/ssh.nix
    ./modules/tmux.nix
    ./modules/yazi.nix
  ];

  # Pins HM's stateful defaults. Set once, never bumped.
  home.stateVersion = "26.05";

  # HM restarts changed user units during activation, so a pueue config edit
  # takes effect on `nixos-rebuild switch` alone.
  systemd.user.startServices = "sd-switch";
}
