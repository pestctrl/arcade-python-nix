{
  description = "Devshell with working arcade pypi package";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs?ref=22.11;
    nixpkgs-unstable.url = github:nixos/nixpkgs?ref=nixos-unstable;
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
  }: let
    supportedSystems = [
      "x86_64-linux"
    ];
    genSystems = nixpkgs.lib.genAttrs supportedSystems;
    unstable = genSystems (system: import nixpkgs-unstable {inherit system;});
    pkgs = genSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [
          (_: super: {
            unstablePymunk = unstable.${super.system}.python310Packages.pymunk;
            unstablePillow = unstable.${super.system}.python310Packages.pillow;
          })
        ];
      });
  in {
    packages = genSystems (system: {
      arcade = pkgs.${system}.callPackage ./default.nix {};
      default = self.packages.${system}.arcade;
    });

    devShell = genSystems (system:
      pkgs.${system}.mkShell {
        packages = with pkgs.${system}; [
          (python310.withPackages
            (ps:
              with ps; [
                self.packages.${system}.arcade
              ]))
        ];
      });
  };
}
