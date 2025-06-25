{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.partitions
  ];
  partitionedAttrs =
    let
      devPartitionName = "dev";
    in
    {
      make-shells = devPartitionName;
      treefmt = devPartitionName;
      pre-commit = devPartitionName;
    };
  partitions.dev = {
    extraInputsFlake = ./dev;
    module = {
      imports = [ ./partition-module.nix ];
    };
  };
}
