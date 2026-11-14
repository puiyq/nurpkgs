lib: scope:
lib.fix (
  packages:
  lib.packagesFromDirectoryRecursive {
    callPackage = lib.callPackageWith (scope // packages);
    directory = ../pkgs/by-name;
  }
)
