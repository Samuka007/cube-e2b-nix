{ lib, ... }:

{
  options.cube.e2b = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "cube-e2b-env";
      description = "OCI image name.";
    };

    tag = lib.mkOption {
      type = lib.types.str;
      default = "latest";
      description = "OCI image tag.";
    };

    envdPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Real E2B envd derivation. If null, uses evaluation-only placeholder.";
    };

    packages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      default = _pkgs: [];
      description = "Function from pkgs to packages included in the sandbox environment.";
    };

    env = lib.mkOption {
      type = lib.types.attrsOf (lib.types.oneOf [ lib.types.str lib.types.int lib.types.bool ]);
      default = {};
      description = "Extra environment variables added to OCI config.";
    };

    workingDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/user";
    };

    cmd = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };

    ports = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [];
      description = "Additional exposed TCP ports. 49983 is always included.";
    };

    enableSudo = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    userName = lib.mkOption {
      type = lib.types.str;
      default = "user";
    };

    uid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
    };

    gid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
    };
  };
}
