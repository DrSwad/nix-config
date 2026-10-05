{ config, lib, osConfig, pkgs, ... }:

let
  ollama = osConfig.services.ollama;

  # Pi compacts against this, so it must be the window ollama actually serves.
  contextWindow = lib.toInt ollama.environmentVariables.OLLAMA_CONTEXT_LENGTH;

  # Bump: the version, plus dist.integrity from
  # https://registry.npmjs.org/@bacnh85/pi-selfskills/latest
  selfskills = pkgs.runCommand "pi-selfskills-0.3.6" {
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@bacnh85/pi-selfskills/-/pi-selfskills-0.3.6.tgz";
      hash = "sha512-pgyn5I0eJ/5IBiwUEBxS5Etda3ZDIlCrIwHc8ZazxoWMlW38T5Vdcmq5rwa0n0IhFyT5UIR45K7Ekzgul2eriQ==";
    };
  } ''
    mkdir $out
    tar -xzf $src -C $out --strip-components=1
  '';

  json = pkgs.formats.json { };

  settings = json.generate "pi-settings.json" {
    defaultProvider = "ollama";
    defaultModel = "qwen3.8:27b-q8_0";

    # A local path rather than `pi install npm:…`, which needs npm at runtime
    # and leaves the version outside this repo.
    packages = [ "${selfskills}" ];

    # Local packages count as patchable by default; this one is in the store.
    selfskills.patchPackages = false;
  };
in
# Pi only talks to the local ollama, so a host without it gets none of this.
{
  # NIXPKGS-PIN: 26.05 is frozen at pi 0.75.4, while Paseo and Pi packages
  # track current releases. Recheck after the next NixOS release.
  home.packages = [ pkgs.unstable.pi-coding-agent ];

  home.file.".pi/agent/models.json".source = json.generate "pi-models.json" {
    providers.ollama = {
      baseUrl = "http://127.0.0.1:${toString ollama.port}/v1";
      api = "openai-completions";
      # Ollama ignores the key, but Pi hides the models of a provider without one.
      apiKey = "ollama";
      # Otherwise reasoning models get the system prompt under the `developer` role.
      compat.supportsDeveloperRole = false;
      models = [
        {
          id = "qwen3.8:27b-q8_0";
          reasoning = true;
          inherit contextWindow;
          # Ollama accepts only none/low/medium/high as reasoning_effort.
          thinkingLevelMap = { off = "none"; minimal = null; };
        }
        {
          id = "gemma4:12b";
          inherit contextWindow;
          # With thinking on, gemma4:12b emits a thinking block and stops without
          # an answer or tool call. Ollama thinks unless told otherwise, so
          # leaving `reasoning` off is not enough.
          samplingParams.reasoning_effort = "none";
        }
      ];
    };
  };

  # A store symlink on purpose: agents can patch skills, not their standing
  # rules. The source is not named AGENTS.md, or Pi would also load it as
  # project context when working under home/modules.
  home.file.".pi/agent/AGENTS.md".source = ./pi-rules.md;

  # Merged rather than linked: Pi writes this file (/model defaults, /settings),
  # which a store symlink would break. The keys above win on every activation,
  # so `pi install` does not survive a rebuild; add packages here instead.
  home.activation.piSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f=${config.home.homeDirectory}/.pi/agent/settings.json
    mkdir -p "$(dirname "$f")"
    [ -s "$f" ] || echo '{}' > "$f"
    ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$f" ${settings} > "$f.tmp"
    mv "$f.tmp" "$f"
  '';
}
