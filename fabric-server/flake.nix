{
  description = "Minecraft Fabric server";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        name = "fabric-server";
      in
      {
        packages.${name} = import ./package.nix { inherit pkgs name; };
        nixosModules.${name} = import ./module.nix { inherit system self name; };
      }
    );
}
