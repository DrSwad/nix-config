{ ... }:

{
  environment.etc."niri/config.kdl".text = ''
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
      Mod+Left  { focus-column-left; }
      Mod+Right { focus-column-right; }
      Mod+Up    { focus-window-up; }
      Mod+Down  { focus-window-down; }
      Mod+Shift+Left  { move-column-left; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+Up    { move-window-up; }
      Mod+Shift+Down  { move-window-down; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+R { switch-preset-column-width; }
      Mod+Comma  { consume-window-into-column; }
      Mod+Period { expel-window-from-column; }
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Print { screenshot; }
      Mod+Shift+E { quit; }
    }
  '';
}
