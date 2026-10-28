{
  description = "swad's NixOS configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Only the NixOS module is used; the daemon comes from nixpkgs-unstable
    # (modules/paseo.nix). If a nixpkgs-unstable bump breaks the service,
    # move this tag to the daemon's version for the matching module.
    paseo = {
      url = "github:getpaseo/paseo/v0.11.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auditory-reader = {
      url = "git+ssh://git@github.com/DrSwad/Auditory-Reader?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs: {
    nixosConfigurations."swad-lab-pc" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/swad-lab-pc/default.nix ];
    };
  };
}
