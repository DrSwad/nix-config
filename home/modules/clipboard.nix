{ pkgs, ... }:

let
  # wl-clipboard for callers whose environment may lack WAYLAND_DISPLAY (tmux
  # jobs, shells opened over ssh). Takes it from the systemd user manager,
  # where niri publishes it.
  inSession = tool: pkgs.writeShellApplication {
    name = "${tool}-session";
    runtimeInputs = [ pkgs.gnused pkgs.systemd pkgs.wl-clipboard ];
    text = ''
      WAYLAND_DISPLAY=$(systemctl --user show-environment | sed -n 's/^WAYLAND_DISPLAY=//p')
      export WAYLAND_DISPLAY
      exec ${tool} "$@"
    '';
  };
in
{
  # wl-copy-session is called by name from tmux.nix and neovim/init.lua.
  home.packages = map inSession [ "wl-copy" "wl-paste" ];
}
