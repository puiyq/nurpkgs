self:
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.security.run0-pkexec-shim;
in
{
  options.security = {
    run0-pkexec-shim = {
      enable = lib.mkEnableOption "run0-pkexec-shim instead of setuid pkexec";
      package = lib.mkPackageOption pkgs "run0-pkexec-shim" { } // {
        default = pkgs.run0-pkexec-shim;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    security = {
      polkit.enable = true;
      wrappers.pkexec = {
        setuid = lib.mkForce false;
        source = lib.mkForce (lib.getExe cfg.package);
      };
    };
  };
}
