{ inputs, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    # Users share the system's pkgs, so nixpkgs.config (allowUnfree) and any
    # overlays apply once rather than being evaluated a second time per user.
    useGlobalPkgs = true;

    # User packages land in /etc/profiles/per-user/$USER instead of a separate
    # nix-env profile, so `nixos-rebuild` alone keeps them in sync.
    useUserPackages = true;

    # A file HM would otherwise refuse to overwrite is moved aside instead.
    backupFileExtension = "hm-bak";
  };
}
