{
  description = "Devshell with working arcade pypi package";

  inputs.nixpkgs.url = github:nixos/nixpkgs?ref=22.11;

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    pkgs = genSystems (system: import nixpkgs {inherit system;});
  in {
    packages = genSystems (system: {
      mazegame = pkgs.${system}.callPackage ./default.nix {};
      default = self.packages.${system}.mazegame;
    });
  };
}
