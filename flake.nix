{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-utils.url = "github:numtide/flake-utils";

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    make-shell = {
      url = "github:nicknovitski/make-shell";
      inputs.flake-compat.follows = "flake-compat";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://pre-commit-hooks.cachix.org"
      "https://fym998-nur.cachix.org"
    ];

    extra-trusted-public-keys = [
      "pre-commit-hooks.cachix.org-1:Pkk3Panw5AW24TOv6kz3PvLhlH8puAsJTBbOPmBo7Rc="
      "fym998-nur.cachix.org-1:lWwztkEXGJsiJHh/5FbA2u95AxJu8/k4udgGqdFLhOU="
    ];
  };

  outputs =
    inputs@{ flake-parts, ... }:
    # https://flake.parts/module-arguments.html
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        config,
        withSystem,
        moduleWithSystem,
        ...
      }:
      {
        debug = true;
        imports = [
          inputs.treefmt-nix.flakeModule
          inputs.git-hooks-nix.flakeModule
          inputs.make-shell.flakeModules.default
        ];
        flake = {
          # Put your original flake attributes here.
        };
        systems = inputs.flake-utils.lib.defaultSystems;
        perSystem =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            treefmt.programs = {
              nixfmt.enable = true;
              statix.enable = true;
            };
            pre-commit.settings.hooks.treefmt = {
              enable = true;
              packageOverrides.treefmt = config.treefmt.build.wrapper;
            };
            make-shells = {
              default = {
                imports =
                  builtins.map
                    (
                      shellModule:
                      builtins.intersectAttrs (lib.genAttrs [
                        "buildInputs"
                        "nativeBuildInputs"
                        "propagatedBuildInputs"
                        "propagatedNativeBuildInputs"
                        "shellHook"
                      ] (_: null)) shellModule
                    )
                    [
                      config.treefmt.build.devShell
                      config.pre-commit.devShell
                    ];
                nativeBuildInputs = builtins.attrValues {
                  inherit (pkgs)
                    nil
                    nix-prefetch-git
                    ;
                };
              };
            };
          };
      }
    );
}
