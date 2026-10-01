{
  description = "swad's NixOS configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tier 2 for upstream: main can break the Nix packaging at any time. Bump on
    # its own and be ready to roll back: nix flake update hermes-agent
    hermes-agent.url = "github:NousResearch/hermes-agent";
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations."swad-lab-pc" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/swad-lab-pc/default.nix ];
    };
  };
}
