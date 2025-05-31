{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-libfprint-1_94_6.url = "github:nixos/nixpkgs/c1f26cac27c78942f0e61a1fff6cdc4a63f02960";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };
  outputs = { self, nixpkgs, nixpkgs-libfprint-1_94_6 }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
        pkgs-libfprint-1_94_6 = import nixpkgs-libfprint-1_94_6 { inherit system; };
      });
      packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
    };
}
