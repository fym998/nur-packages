# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{
  pkgs,
  pkgs-libfprint-1_94_6,
  system ? builtins.currentSystem,
}: 
  {
    bitsrun-rs = pkgs.callPackage ./pkgs/bitsrun-rs {};
  }
  // (
    if system == "x86_64-linux"
    then {
      let
        libfprint-fpcmoh = pkgs-libfprint-1_94_6.callPackage ./pkgs/libfprint-fpcmoh {};
        fprintd-fpcmoh = pkgs-libfprint-1_94_6.fprintd.override {
          libfprint = libfprint-fpcmoh;
        };
      in {
        inherit libfprint-fpcmoh fprintd-fpcmoh;
      };
    }
    else {}
  )
