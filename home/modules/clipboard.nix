{ pkgs, ... }:

{
  home.packages = [
    # wl-copy for callers whose environment may lack WAYLAND_DISPLAY (tmux
    # jobs, panes in a server started over ssh). Takes it from the systemd
    # user manager, where niri publishes it. Called by name from tmux.nix
    # and neovim/init.lua.
    (pkgs.writeShellApplication {
      name = "wl-copy-session";
      runtimeInputs = [ pkgs.gnused pkgs.systemd pkgs.wl-clipboard ];
      text = ''
        WAYLAND_DISPLAY=$(systemctl --user show-environment | sed -n 's/^WAYLAND_DISPLAY=//p')
        export WAYLAND_DISPLAY
        exec wl-copy
      '';
    })
  ];
}
