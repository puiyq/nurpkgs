pkgs: lib:
lib.fix (
  self:
  lib.packagesFromDirectoryRecursive {
    callPackage = lib.callPackageWith (pkgs // self);
    directory = ./by-name;
  }
)
