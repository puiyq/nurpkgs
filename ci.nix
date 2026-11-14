# Buildable and cacheable package outputs from the flake's locked Nixpkgs.
{
  system ? builtins.currentSystem,
}:

let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  nixpkgsNode = lock.nodes.${lock.nodes.root.inputs.nixpkgs};
  nixpkgs = fetchTarball {
    inherit (nixpkgsNode.locked) url;
    sha256 = nixpkgsNode.locked.narHash;
  };
  pkgs = import nixpkgs { inherit system; };
  packages = (import ./lib/mk-packages.nix) pkgs.lib pkgs;

  isDerivation = package: builtins.isAttrs package && (package.type or null) == "derivation";
  isBuildable =
    package:
    let
      license = package.meta.license or [ ];
      licenses = if builtins.isList license then license else [ license ];
    in
    !(package.meta.broken or false) && builtins.all (item: item.free or true) licenses;
  isCacheable = package: !(package.preferLocalBuild or false);

  flattenPackages =
    value:
    if isDerivation value then
      [ value ]
    else if builtins.isAttrs value then
      builtins.concatLists (map flattenPackages (builtins.attrValues value))
    else
      [ ];

  packageList = builtins.concatLists (map flattenPackages (builtins.attrValues packages));
  buildPkgs = builtins.filter isBuildable packageList;
  cachePkgs = builtins.filter isCacheable buildPkgs;
  outputsOf = package: map (output: package.${output}) package.outputs;
in
{
  inherit buildPkgs cachePkgs;
  buildOutputs = builtins.concatLists (map outputsOf buildPkgs);
  cacheOutputs = builtins.concatLists (map outputsOf cachePkgs);
}
