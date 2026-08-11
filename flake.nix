{
  description = "swad's NixOS configs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations."swad-lab-pc" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/swad-lab-pc/default.nix ];
    };
  };
}
