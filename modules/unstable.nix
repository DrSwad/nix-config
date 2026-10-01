{ inputs, ... }:

{
  # Bump: nix flake update nixpkgs-unstable. This also moves ollama-cuda — run
  # the dry-run in modules/ollama.nix first to confirm it still comes from cache.
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };

      # Stable trails upstream by weeks.
      claude-code = final.unstable.claude-code;
    })
  ];
}
