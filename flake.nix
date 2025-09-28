{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-minecraft,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.kormoran = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          nix-minecraft.nixosModules.minecraft-servers
          {
            nixpkgs.overlays = [
              inputs.nix-minecraft.overlay
            ];
          }
        ];
      };
    };
}
