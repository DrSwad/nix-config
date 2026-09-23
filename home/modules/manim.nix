{ lib, osConfig, pkgs, ... }:

let
  py = pkgs.python3Packages;

  # An env rather than pkgs.manim-slides, so basedpyright can resolve manim
  # and manim_slides imports.
  env = pkgs.python3.buildEnv.override {
    extraLibs = [ py.manim-slides ] ++ py.manim-slides.optional-dependencies.pyqt6-full;

    # NIXPKGS-PIN: manim 0.20.1 puts ffmpeg and its TeX Live on PATH only in
    # its own bin/manim wrapper. `manim-slides render` and `python -m manim`
    # bypass it, so MathTex can't find latex unless the args are copied here.
    makeWrapperArgs = py.manim.makeWrapperArgs ++ [
      # No Qt wrapper on this env, so without this QtMultimedia finds no
      # backend and the presenter plays a black screen.
      "--prefix" "QT_PLUGIN_PATH" ":" "${pkgs.qt6.qtmultimedia}/${pkgs.qt6.qtbase.qtPluginPrefix}"
    ];
  };

  preview = pkgs.writeShellApplication {
    name = "manim-preview";
    runtimeInputs = [ env pkgs.watchexec ];
    text = ''
      if [ $# -lt 2 ]; then
        echo "usage: manim-preview FILE SCENE..." >&2
        exit 1
      fi
      file=$1
      shift
      # shellcheck disable=SC2016
      exec watchexec --restart --clear --exts py --shell=none -- \
        sh -c 'f=$1; shift; manim-slides render "$f" "$@" --quality=l && manim-slides present --hide-info-window "$@"' \
        sh "$file" "$@"
    '';
  };

  # --quality=X throughout: `manim-slides render` owns -h, so `-qh` prints
  # its help instead of rendering.
  export = pkgs.writeShellApplication {
    name = "manim-export";
    runtimeInputs = [ env ];
    text = ''
      if [ $# -lt 2 ]; then
        echo "usage: manim-export FILE SCENE..." >&2
        exit 1
      fi
      file=$1
      shift
      manim-slides render "$file" "$@" --quality=h
      manim-slides convert "$@" "''${file%.py}.html" --one-file --offline
    '';
  };
in
{
  home.packages = [ env preview export ];

  # Floating because niri doesn't scroll to an unfocused tiled column, which
  # leaves it off-screen.
  xdg.configFile."niri/config.kdl".text = lib.mkIf (osConfig.swad.niri.previewOutput != null) ''
    window-rule {
      match title="^Manim Slides$"
      open-on-output "${osConfig.swad.niri.previewOutput}"
      open-focused false
      open-floating true
      default-column-width { proportion 0.5; }
      default-window-height { proportion 0.5; }
      default-floating-position x=0 y=0 relative-to="top-right"
    }
  '';
}
