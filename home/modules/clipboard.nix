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

  # Thumbnails are rebuilt on every run because cliphist ids restart after
  # `cliphist wipe`. The wl-copy type is explicit because its own guess
  # depends on xdg-mime being on PATH.
  clip = pkgs.writeShellApplication {
    name = "clip";
    runtimeInputs = [ pkgs.cliphist pkgs.rofi pkgs.wl-clipboard ];
    text = ''
      re=$'^([0-9]+)\t\\[\\[ binary data .* (png|jpeg|gif|bmp|webp) [0-9]+x[0-9]+ \\]\\]$'
      thumbs=''${XDG_RUNTIME_DIR:?}/clip-thumbs
      rm -rf "$thumbs"
      mkdir -p "$thumbs"

      pick=$(
        cliphist list | while IFS= read -r line; do
          if [[ $line =~ $re ]]; then
            img=$thumbs/''${BASH_REMATCH[1]}.''${BASH_REMATCH[2]}
            cliphist decode <<<"$line" >"$img"
            printf '%s\0icon\x1f%s\n' "$line" "$img"
          else
            printf '%s\n' "$line"
          fi
        done | rofi -dmenu -i -show-icons -display-columns 2 -p clip \
          -theme-str 'element-icon { size: 2.5em; }'
      ) || exit 0

      if [[ $pick =~ $re ]]; then
        cliphist decode <<<"$pick" | wl-copy --type "image/''${BASH_REMATCH[2]}"
      else
        cliphist decode <<<"$pick" | wl-copy --type text/plain
      fi
    '';
  };
in
{
  # Called by name: wl-copy-session from tmux.nix and neovim/init.lua, clip from niri.nix.
  home.packages = map inSession [ "wl-copy" "wl-paste" ] ++ [ clip ];

  services.cliphist = {
    enable = true;
    extraOptions = [ "-max-dedupe-search" "10" "-max-items" "500" ];
  };
}
