{ pkgs }:

# Sketch of the real envd package. Kept as a template because the exact
# sha256/vendorHash must be filled by a real build on a machine with enough
# space/network budget.
#
# Usage:
#   realEnvd = pkgs.callPackage ./pkgs/envd-e2b.nix {
#     srcHash = "sha256-...";
#     vendorHash = "sha256-...";
#   };
{ version ? "2026.16"
, srcHash
, vendorHash
}:

pkgs.buildGoModule {
  pname = "envd";
  inherit version vendorHash;

  src = pkgs.fetchFromGitHub {
    owner = "e2b-dev";
    repo = "infra";
    rev = version;
    hash = srcHash;
  };

  sourceRoot = "source/packages/envd";

  CGO_ENABLED = 0;

  ldflags = [
    "-s"
    "-w"
    "-X=main.commitSHA=${version}"
  ];

  meta = {
    description = "E2B envd daemon for CubeSandbox/E2B-compatible sandboxes";
    license = pkgs.lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
