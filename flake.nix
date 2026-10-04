{
  description = "swad's NixOS configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No nixpkgs follows: the package's npmDepsHash is only valid against the
    # nixpkgs that upstream pins. Bump by changing the tag, then
    # `nix flake update paseo`, and keep the client apps on a matching version.
    paseo.url = "github:getpaseo/paseo/v0.10.3";
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations."swad-lab-pc" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/swad-lab-pc/default.nix ];
    };
  };
}
