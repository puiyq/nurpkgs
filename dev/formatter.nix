{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem.treefmt =
    { lib, pkgs, ... }:
    {
      projectRootFile = "flake.nix";
      programs = {
        biome.enable = true;
        deadnix.enable = true;
        nixfmt = {
          enable = true;
          package = pkgs.nixfmt-rs;
        };
        rustfmt.enable = true;
        statix.enable = true;
        taplo.enable = true;
      };
      settings.formatter.nufmt = {
        command = lib.getExe pkgs.nufmt;
        includes = [ "*.nu" ];
      };
    };
}
