{ config, lib, pkgs, ... }:

let
  # alias -> model pulled. `ollama cp` only writes a new manifest against the
  # same blobs, so an alias costs no disk. A bare `qwen` would collide with the
  # built-in Qwen Cloud provider in hermes' /model command, hence qwen3.
  aliases = {
    gemma = "gemma4:12b";
    qwen3 = "qwen3.8:27b-q8_0";
  };

  ollama = lib.getExe config.services.ollama.package;
in
{
  # Unfree CUDA builds never reach cache.nixos.org; without this, every
  # nixpkgs-unstable bump compiles ollama's CUDA kernels locally.
  nix.settings = {
    extra-substituters = [ "https://cache.nixos-cuda.org" ];
    extra-trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
  };

  services.ollama = {
    enable = true;

    # NIXPKGS-PIN: 26.05 ships ollama 0.32.3, but qwen3.8 needs >= 0.32.12. Move
    # back to stable once it carries a new enough ollama.
    # After a nixpkgs-unstable bump, this should fetch ollama, not build it:
    #   nix build --dry-run .#nixosConfigurations.swad-lab-pc.config.services.ollama.package
    # If it builds, cache.nixos-cuda.org hasn't caught up with that rev yet.
    package = pkgs.unstable.ollama-cuda;

    loadModels = lib.attrValues aliases;

    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "15m";
      # The GPU is shared with training, so a model switch must evict, not stack.
      OLLAMA_MAX_LOADED_MODELS = "1";
      # Hermes refuses to work below 64K.
      OLLAMA_CONTEXT_LENGTH = "131072";
      # The quantized KV cache is ignored unless flash attention is on.
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
  };

  # On the loader rather than the server, so the sources exist first.
  systemd.services.ollama-model-loader.postStart = lib.concatStrings (
    lib.mapAttrsToList (alias: model: "${ollama} cp ${model} ${alias} || true\n") aliases
  );
}
