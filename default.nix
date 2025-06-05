# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
}:
let
  # 读取 pkgs 目录下的所有子目录
  packagesDir = ./pkgs;
  packageNames = lib.attrNames (builtins.readDir packagesDir);

  # 为每个子目录创建对应的 callPackage 调用
  mkPackage = name: {
    inherit name;
    value = pkgs.callPackage (packagesDir + "/${name}") { };
  };

  # 生成属性集
  packages = builtins.listToAttrs (map mkPackage packageNames);
in
packages
