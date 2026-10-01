{ config, inputs, osConfig, pkgs, ... }:

let
  ollamaUrl = "http://127.0.0.1:${toString osConfig.services.ollama.port}/v1";
in
{
  imports = [ inputs.hermes-agent.homeManagerModules.default ];

  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;

    # Long-running process for Telegram; users.users.swad.linger keeps it up.
    gateway.enable = true;

    # The bind address is the only Host header the server accepts, so every
    # client uses this exact name — the short hostname is refused.
    backend = {
      mode = "dashboard";
      host = osConfig.swad.hermes.bindHost;
    };

    # dashboard mode keeps /api/ws closed unless embedded chat is on.
    environment.HERMES_DASHBOARD_TUI = "1";

    # The unit's PATH is hermes + bash, coreutils and git only. The agent drives
    # a tmux session that runs `nix develop`, and the pane inherits this PATH.
    extraPackages = with pkgs; [
      nix
      tmux
      gnugrep
      gnused
      which
    ];

    # Untracked, 0600, outside this repo: Telegram bot token and dashboard password.
    environmentFiles = [ "${config.home.homeDirectory}/.config/hermes/secrets.env" ];

    settings = {
      model = {
        default = "qwen3.8:27b-q8_0";
        provider = "ollama-local";
        base_url = ollamaUrl;
        # Hermes sends its own num_ctx per request, overriding the server's
        # OLLAMA_CONTEXT_LENGTH, and otherwise detects the model's 262K maximum.
        # context_length caps detection; ollama_num_ctx is what ollama receives.
        context_length = 131072;
        ollama_num_ctx = 131072;
      };

      # A named provider: the picker reports a bare `custom` as unauthenticated,
      # and per-model values here survive a /model switch, unlike model.context_length.
      providers.ollama-local = {
        base_url = ollamaUrl;
        # Ollama ignores credentials, but an entry without a key reads as unauthenticated.
        api_key = "ollama";
        models = {
          "gemma4:12b" = { context_length = 131072; };
          "qwen3.8:27b-q8_0" = { context_length = 131072; };
          # The aliases from modules/ollama.nix; `ollama cp` tags them :latest.
          "gemma:latest" = { context_length = 131072; };
          "qwen3:latest" = { context_length = 131072; };
        };
      };

      # Matches OLLAMA_KEEP_ALIVE: a reply arriving after an idle unload waits
      # for a 29 GB reload rather than timing out.
      request_timeout = 1800;
      stream_read_timeout = 1800;

      # gemma4:12b emits a thinking block and then stops without an answer or a
      # tool call; hermes then posts the raw reasoning. qwen3.8 is fine with thinking.
      agent.reasoning_overrides."gemma4:12b" = "none";

      # A /model switch drops the configured context_length and falls back to the
      # detected 262K, so a ratio threshold alone would let a session outgrow
      # ollama's window. This absolute cap fires first and survives switches.
      compression.threshold_tokens = 100000;

      # A non-loopback bind fails closed without an auth provider; the password
      # is in secrets.env.
      dashboard.basic_auth.username = "swad";
    };
  };
}
