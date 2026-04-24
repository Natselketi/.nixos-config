{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-audiorelay.url = "github:vleeuwenmenno/nix-audiorelay";
  };
  outputs = { self, nixpkgs, nix-gaming, nix-audiorelay }@inputs: {
      nixosConfigurations.nakamura-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./configuration.nix
          inputs.nix-audiorelay.nixosModules.audiorelay {programs.audiorelay.enable = true;}
        ];
    };
  };
}

