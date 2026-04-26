{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-audiorelay.url = "github:vleeuwenmenno/nix-audiorelay";
    heroic.url = "github:nixos/nixpkgs?ref=5a4bd9ef2d2b802304eb386e6f53026cc528382d";
  };
  outputs = { self, nixpkgs, nixpkgs-master, ... }@inputs: {
      nixosConfigurations.nakamura-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./configuration.nix
          inputs.nix-audiorelay.nixosModules.audiorelay {programs.audiorelay.enable = true;}
        ];
    };
  };
}

