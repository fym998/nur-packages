{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-libfprint-1_94_6.url = "github:nixos/nixpkgs/c1f26cac27c78942f0e61a1fff6cdc4a63f02960";

    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-libfprint-1_94_6,
      flake-utils,
      pre-commit-hooks,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        result = import ./default.nix {
          inherit system pkgs;
          pkgs-libfprint-1_94_6 =
            if system == "x86_64-linux" then import nixpkgs-libfprint-1_94_6 { inherit system; } else null;
        };
        packagesForx86_64Linux =
          if system == "x86_64-linux" then
            let
              libfprint-fpcmoh = result.libfprint-fpcmoh;
              fprintd-fpcmoh = result.fprintd-fpcmoh;
            in
            {
              inherit libfprint-fpcmoh fprintd-fpcmoh;
            }
          else
            { };
        packages = {
          bitsrun-rs = result.bitsrun-rs;
        } // packagesForx86_64Linux;
      in
      {
        inherit packages;
        legacyPackages = packages;

        formatter = pkgs.nixfmt-rfc-style;

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
            };
          };
        };

        devShells = {
          default = pkgs.mkShellNoCC {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
          };
        };

      }
    );
}
