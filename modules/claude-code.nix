{ inputs, ... }:

{
  # Stable trails upstream by weeks. Bump on its own: nix flake update nixpkgs-unstable
  nixpkgs.overlays = [
    (_: prev: {
      claude-code =
        (import inputs.nixpkgs-unstable {
          inherit (prev.stdenv.hostPlatform) system;
          config.allowUnfree = true;
        }).claude-code;
    })
  ];
}
