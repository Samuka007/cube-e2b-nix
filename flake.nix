{
  description = "Nix-built E2B/CubeSandbox-compatible OCI images";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs }:
  let
    systems = [ "x86_64-linux" ];
    forAllSystems = f:
      nixpkgs.lib.genAttrs systems (system:
        f {
          inherit system;
          pkgs = import nixpkgs { inherit system; };
        });
  in {
    lib = forAllSystems ({ pkgs, ... }:
      import ./lib {
        inherit pkgs;
        inherit (pkgs) lib;
      });

    packages = forAllSystems ({ system, pkgs, ... }:
      let
        e2b = self.lib.${system};
      in {
        minimalImage = e2b.mkMinimalImage {
          name = "cube-e2b-minimal";
          tag = "latest";
        };

        dataImage = e2b.mkE2BImageFromModule ./examples/data-env/module.nix;
      });
  };
}
