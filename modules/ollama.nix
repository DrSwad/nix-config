{ pkgs, ... }:

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

    loadModels = [ "gemma4:12b" "qwen3.8:27b-q8_0" ];

    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "15m";
      # The GPU is shared with training, so a model switch must evict, not stack.
      OLLAMA_MAX_LOADED_MODELS = "1";
      # Pi uses the OpenAI-compatible endpoint, which has no per-request num_ctx,
      # so this is the only place the window is set. home/modules/pi.nix reads
      # it as Pi's contextWindow.
      OLLAMA_CONTEXT_LENGTH = "131072";
      # The quantized KV cache is ignored unless flash attention is on.
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
  };
}
