{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";
  };
  outputs = { self, nixpkgs, nix-gaming }@inputs: {
      nixosConfigurations.nakamura-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [ ./configuration.nix ];
    };
  };
}

