{ ... }:

{
  programs.qutebrowser = {
    enable = true;

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
