# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{
  pkgs,
  system ? builtins.currentSystem,
}:
{
  bitsrun-rs = pkgs.callPackage ./pkgs/bitsrun-rs { };
  libfprint-fpcmoh = pkgs.callPackage ./pkgs/libfprint-fpcmoh { };
  fprintd-fpcmoh = pkgs.callPackage ./pkgs/fprintd-fpcmoh { };
}
