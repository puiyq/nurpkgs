{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.partitions ];

  partitionedAttrs = {
    formatter = "dev";
    apps = "dev";
  };

  partitions.dev = {
    extraInputsFlake = ./.;
    module.imports = [
      ./formatter.nix
      ./update.nix
    ];
  };
}
