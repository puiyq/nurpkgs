{ self }:
let
  modules = removeAttrs (builtins.readDir ./.) [ "default.nix" ];
in
builtins.mapAttrs (name: _: (import (./. + "/${name}")) { inherit self; }) modules
