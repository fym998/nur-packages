# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}, pkgs-libfprint-1_94_6}:
  let
    libfprint-fpcmoh = pkgs-libfprint-1_94_6.callPackage ./pkgs/libfprint-fpcmoh {};
  in{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  example-package = pkgs.callPackage ./pkgs/example-package {};
  bitsrun-rs = pkgs.callPackage ./pkgs/bitsrun-rs {};
  inherit libfprint-fpcmoh;
  fprintd-fpcmoh = pkgs-libfprint-1_94_6.fprintd.override { libfprint = libfprint-fpcmoh; };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
