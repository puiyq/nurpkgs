{
  perSystem =
    { lib, pkgs, ... }:
    {
      apps.update.program = lib.getExe (
        pkgs.writeShellApplication {
          name = "update";
          runtimeInputs = with pkgs; [
            nushell
            git
            gh
          ];
          text = ''exec nu ${../.github/scripts/update.nu} "$@"'';
        }
      );
    };
}
