{ pkgs, ... }:

{
  programs.qutebrowser = {
    enable = true;

    # NIXPKGS-PIN: QtWebEngine 6.11 sometimes skips qutebrowser's injected JS
    # after a navigation (qutebrowser#8925), breaking hints until reload. This is
    # the unmerged qutebrowser#8940, which covers hints only. Drop it once
    # `:open -t github.com/qutebrowser/qutebrowser` then `f` shows hints without it.
    package = pkgs.qutebrowser.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [ ./qutebrowser-qt611-hints.patch ];
    });

    # Untracked autoconfig.yml holds per-site permissions granted from prompts.
    loadAutoconfig = true;

    # Not via `settings`: HM flattens nested attrs into option paths, so a dict
    # key becomes part of the option name. Mutating keeps the default entry.
    # qutebrowser/qutebrowser#7846, unfixed in 3.7.0: hinting a contenteditable
    # with role=textbox throws in its own move_cursor_to_end. Drop once fixed.
    extraConfig = ''
      c.content.javascript.log_message.excludes["userscript:_qute_js"] = [
          "*Cannot read properties of undefined (reading 'length')"
      ]
    '';

    # Key presses reach inner scroll containers (e.g. claude.ai's chat); the
    # default scroll-to-perc only scrolls the document via window.scroll().
    keyBindings.normal = {
      gg = "scroll top";
      G = "scroll bottom";
    };
  };
}
