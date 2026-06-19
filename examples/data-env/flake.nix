{
  description = "Template: downstream data environment using cube-e2b-nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Replace this with your repo URL or an absolute local path while developing.
    # Do not use path:../.. inside a nested flake: pure eval copies the child
    # flake to /nix/store, so upward relative paths escape the store and fail.
    cube-e2b-nix.url = "github:your-org/cube-e2b-nix";
  };

  outputs = { self, nixpkgs, cube-e2b-nix }:
  let
    system = "x86_64-linux";
    e2b = cube-e2b-nix.lib.${system};
  in {
    packages.${system}.dataImage = e2b.mkE2BImageFromModule ./module.nix;
  };
}
