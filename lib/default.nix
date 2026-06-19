{ lib, pkgs }:

let
  mkE2BImage = pkgs.callPackage ./mk-e2b-image.nix {};

  mkE2BImageFromModule = module:
    let
      evaluated = lib.evalModules {
        specialArgs = { inherit pkgs; };
        modules = [ ./module.nix ] ++ lib.toList module;
      };
      cfg = evaluated.config.cube.e2b;
      args = {
        inherit (cfg) name tag packages workingDir cmd enableSudo userName uid gid;
        extraEnv = cfg.env;
        extraPorts = cfg.ports;
      } // lib.optionalAttrs (cfg.envdPackage != null) {
        envdPackage = cfg.envdPackage;
      };
    in
      mkE2BImage args;

  mkMinimalImage = { name ? "cube-e2b-minimal", tag ? "latest", envdPackage ? null }:
    mkE2BImageFromModule {
      cube.e2b = {
        inherit name tag envdPackage;
        packages = _pkgs: [];
      };
    };

in {
  inherit mkE2BImage mkE2BImageFromModule mkMinimalImage;
}
