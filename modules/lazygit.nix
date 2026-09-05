{ ... }:

{
  # Settings land in /etc/xdg/lazygit/config.yml, not ~/.config/lazygit/, which
  # leaves that directory writable for state.yml — recent repos, panel sizes,
  # diff context size — that lazygit rewrites constantly.
  programs.lazygit = {
    enable = true;

    # Every key below was checked against `lazygit -c` on 0.61.1, the version in
    # nixpkgs 26.05. Lazygit rewrites its config file in place when a key is
    # renamed upstream, and that write fails against a read-only store path, so
    # it refuses to start until the rename is applied here. Only keys actually
    # set can trigger this, which is why this block stays small. Case in point:
    # git.pagers is absent here, and was renamed to git.diffRenderers by lazygit 0.64.
    settings = {
      gui = {
        # nerd-fonts.jetbrains-mono from common.nix is a v3 font. showFileIcons
        # already defaults true, but does nothing until this is non-empty.
        nerdFontsVersion = "3";

        # These fire on every A and every R. Both are part of the routine
        # amend-and-force-push loop, so the confirmation is just a keystroke.
        skipAmendWarning = true;
        skipRewordInEditorWarning = true;

        # How far the branch has drifted from its base, visible in the branches
        # panel — so a rebase that will need a force push is obvious before P.
        showDivergenceFromBaseBranch = "arrowAndNumber";
      };

      # The binary is immutable, so the update check can only ever waste time.
      update.method = "never";

      disableStartupPopups = true;

      # Default makes you press enter after every subprocess returns, including
      # every `e` into vim.
      promptToReturnFromSubprocess = false;

      # Outside a repo, quit instead of offering to run git init.
      notARepository = "quit";
    };
  };
}
