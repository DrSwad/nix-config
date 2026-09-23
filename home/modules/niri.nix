{ osConfig, pkgs, ... }:

{
  home.packages = [ pkgs.swaylock ];

  xdg.configFile."niri/config.kdl".text = ''
    ${osConfig.swad.niri.outputs}
    input {
      keyboard {
        xkb {
          layout "us"
        }
      }
    }
    binds {
      Mod+Shift+Slash { show-hotkey-overlay; }
      Mod+Shift+E { quit; }
      Print { screenshot; }

      Mod+Return hotkey-overlay-title="Terminal: ghostty" { spawn "ghostty"; }
      Mod+Space hotkey-overlay-title="App Launcher: rofi" { spawn "rofi" "-show" "drun"; }
      Mod+Q { close-window; }
      Super+Alt+L hotkey-overlay-title="Lock the Screen: swaylock" { spawn "${pkgs.swaylock}/bin/swaylock" "-f" "-c" "1a1a1a"; }

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

      Mod+V       { toggle-window-floating; }
      Mod+Shift+V { switch-focus-between-floating-and-tiling; }
    }
  '';
}
