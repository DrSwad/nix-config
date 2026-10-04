{ ... }:

{
  programs.gh = {
    enable = true;

    # config.yml is a read-only store symlink, so `gh config set` and
    # `gh alias set` fail; add settings here instead. `gh auth login` also
    # ends with a "read-only file system" error, after it has saved the token.
    settings.git_protocol = "ssh";

    # Git reaches GitHub over SSH, so the HTTPS credential helper is unused.
    gitCredentialHelper.enable = false;
  };
}
