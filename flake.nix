{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    fabric-server.url = "path:./fabric-server";
  };

  outputs = { nixpkgs, fabric-server, ... }:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.kormoran = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          fabric-server.nixosModules.${system}.fabric-server
        ];
      };
    };
}
