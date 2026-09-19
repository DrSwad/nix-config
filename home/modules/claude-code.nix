{ ... }:

{
  # settings stays unset: HM would make ~/.claude/settings.json a read-only
  # store symlink, and Claude Code writes to it (e.g. /model saving a default).
  programs.claude-code.enable = true;
}
