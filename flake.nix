{
  description = "Nix-built E2B/CubeSandbox-compatible OCI images";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org/"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWkTptE9HnePt8N7m7qnd6NdbJcc="
    ];
  };

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
        envd = pkgs.callPackage ./pkgs/envd-e2b.nix {};
      in {
        inherit envd;

        minimalImage = e2b.mkMinimalImage {
          name = "cube-e2b-minimal";
          tag = "latest";
          envdPackage = envd;
        };

        dataImage = e2b.mkE2BImageFromModule [
          ./examples/data-env/module.nix
          { cube.e2b.envdPackage = envd; }
        ];
      });
  };
}
