{ config, lib, ... }:

let
  cfg = config.swad.niri;
in
{
  options.swad.niri.outputs = lib.mkOption {
    type = lib.types.lines;
    default = "";
    example = ''
      output "DP-1" {
        position x=0 y=0
      }
    '';
    description = ''
      Per-host `output` blocks, spliced into the top of /etc/niri/config.kdl.
      Host-scoped because it names physical monitors.

      Outputs match on connector name or on "make model serial" as printed by
      `niri msg outputs`. Prefer the latter for identical panels: connector
      names follow the cable, not the monitor.

      Empty means niri auto-places outputs, sorting by connector name and
      laying them out left to right.
    '';
  };

  config = {
    environment.etc."niri/config.kdl".text = ''
      ${cfg.outputs}
      input {
        keyboard {
          xkb {
            layout "us"
          }
        }
      }
      binds {
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+Return hotkey-overlay-title="Terminal: ghostty" { spawn "ghostty"; }
        Mod+Q { close-window; }
        Print { screenshot; }
        Mod+Shift+E { quit; }

        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+Up    { focus-window-up; }
        Mod+Down  { focus-window-down; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Down  { move-window-down; }

        Mod+Ctrl+Left  { focus-monitor-left; }
        Mod+Ctrl+Right { focus-monitor-right; }
        Mod+Ctrl+Shift+Left  { move-column-to-monitor-left; }
        Mod+Ctrl+Shift+Right { move-column-to-monitor-right; }

        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+R { switch-preset-column-width; }

        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
      }
    '';
  };
}
