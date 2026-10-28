{ pkgs, ... }:

let
  define = pkgs.writeShellApplication {
    name = "define";
    runtimeInputs = [ pkgs.coreutils pkgs.gnused pkgs.rofi pkgs.wordnet ];
    text = ''
      word=$(rofi -dmenu -p define -theme-str 'listview { enabled: false; }' </dev/null) || exit 0
      [ -n "$word" ] || exit 0

      # wn exits with the number of senses found, so its status is not an error signal.
      out=$(wn "''${word// /_}" -over || true)
      if [ -z "$out" ]; then
        rofi -e "No definition for: $word"
        exit 0
      fi

      sed -E -e '/^$/d' -e '/^The .* has [0-9]+ senses?/d' \
        -e 's/^Overview of (.*)/── \1 ──/' -e 's/^([0-9]+\.) \([0-9]+\) /\1 /' <<<"$out" \
        | fold -s -w 120 \
        | rofi -dmenu -i -no-custom -p "$word" \
          -theme-str 'window { width: 128ch; } listview { lines: 20; }' >/dev/null || true
    '';
  };
in
{
  home.packages = [ define ];
}
