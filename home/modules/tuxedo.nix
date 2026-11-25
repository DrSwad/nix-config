{ lib, pkgs, ... }:

let
  tuxedo-unwrapped = pkgs.unstable.tuxedo.overrideAttrs (old: {
    # Upstream #151 (fixes #99, blank list after closing the editor), merged
    # after 2026.8.1. Drop once a release includes it.
    patches = (old.patches or [ ]) ++ [ ./tuxedo-redraw-after-editor.patch ];

    # Upstream hardcodes O-created notes under projects/tuxedo-tasks/ (as of
    # 2026.8.1). The skipped tests assert that path. Drop this if it becomes
    # configurable.
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/note.rs \
        --replace-fail 'format!("{DEFAULT_NOTES_SUBDIR}/{slug}.md")' 'format!("{slug}.md")'
    '';
    checkFlags = (old.checkFlags or [ ]) ++ [
      "--skip=create_or_open_note_appends_link_creates_file_and_queues_editor"
      "--skip=creates_default_slug_path_when_task_has_no_note_token"
    ];
  });

  # tuxedo itself only checks ./todo.txt, never parent dirs (as of 2026.8.1).
  # A notes_dir key in ~/.config/tuxedo/config.toml outranks NOTES_DIR.
  tuxedo = pkgs.writeShellApplication {
    name = "tuxedo";
    text = ''
      dir=$PWD
      while [ "$dir" != / ] && [ ! -f "$dir/.todo/todo.txt" ]; do
        dir=$(dirname "$dir")
      done
      if [ -f "$dir/.todo/todo.txt" ]; then
        export TODO_DIR="$dir/.todo" NOTES_DIR="$dir/.todo/notes"
      elif [ $# -eq 0 ]; then
        echo "tuxedo: no .todo/todo.txt here or in any parent. Start one with: mkdir .todo && touch .todo/todo.txt" >&2
        exit 1
      else
        unset TODO_DIR NOTES_DIR
      fi
      exec ${lib.getExe tuxedo-unwrapped} "$@"
    '';
  };
in
{
  # NIXPKGS-PIN: 26.05 doesn't package tuxedo. Move to pkgs.tuxedo once stable
  # carries a release at least as new as unstable's.
  home.packages = [ tuxedo ];

  # The binary is immutable, so the status bar's upgrade hint can't be acted on.
  home.sessionVariables.TUXEDO_NO_UPDATE_CHECK = "1";
}
