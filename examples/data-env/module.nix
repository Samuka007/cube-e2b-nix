{ pkgs, ... }:

{
  cube.e2b = {
    name = "cube-e2b-data";
    tag = "latest";

    packages = pkgs: with pkgs; [
      python312
      python312Packages.numpy
      python312Packages.pandas
      python312Packages.matplotlib
      duckdb
      sqlite
      jq
    ];

    env = {
      PYTHONUNBUFFERED = "1";
    };

    workingDir = "/home/user";
    ports = [ 8888 ];
  };
}
