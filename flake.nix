{
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-gaming.url = "github:fufexan/nix-gaming";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    sls-steam = { url = "github:AceSLS/SLSsteam"; inputs.nixpkgs.follows = "nixpkgs"; };
    osu-lazer.url = "github:nixos/nixpkgs?ref=7413e8c550bd4b196fb4d4ba39243efd10ae3d5e";
    nur = { url = "github:nix-community/NUR"; inputs.nixpkgs.follows = "nixpkgs"; };
  };
  outputs = { self, nixpkgs, nur, ... }@inputs: {
      nixosConfigurations.nakamura-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./configuration.nix
          nur.modules.nixos.default
        ];
    };
  };
}
