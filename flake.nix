{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-compat = {
      url = "https://git.lix.systems/lix-project/flake-compat/archive/main.tar.gz";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [ ./dev/partition.nix ];

      perSystem =
        {
          pkgs,
          lib,
          self',
          ...
        }:
        {
          packages = self.lib.mkPackages lib pkgs;

          devShells = {
            run0-pkexec-shim = pkgs.mkShell {
              inputsFrom = [ self'.packages.run0-pkexec-shim ];
              packages = with pkgs; [
                rust-analyzer
                clippy
                rustfmt
              ];
            };
            lycosa = pkgs.mkShell {
              inputsFrom = [ self'.packages.lycosa ];
              packages = with pkgs; [
                typescript
              ];
            };
          };
        };

      flake = {
        lib = import ./lib;
        nixosModules = import ./nixos-modules { inherit self; };
        overlays = {
          default = final: _: self.lib.mkPackages inputs.nixpkgs.lib final;
        };
      };

    };
}
