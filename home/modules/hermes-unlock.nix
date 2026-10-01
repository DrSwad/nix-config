{ pkgs, ... }:

{
  # The web dashboard spawns one tui_gateway child per chat and never reaps it
  # when the tab closes, so the session's lease is held by a live process and
  # the chat can't be resumed anywhere else (upstream NousResearch/hermes-agent
  # #122365, #122725). Killing the orphans releases every idle lease; a chat
  # open in a live tab reclaims its own on the next message.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "hermes-unlock";
      runtimeInputs = [ pkgs.procps ];
      text = ''
        n=$(pgrep -cf tui_gateway.entry || true)
        pkill -f tui_gateway.entry || true
        echo "released $n chat worker(s)"
      '';
    })
  ];
}
