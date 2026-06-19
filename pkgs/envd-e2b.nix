{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "envd";
  version = "2026.16";

  src = fetchFromGitHub {
    owner = "e2b-dev";
    repo = "infra";
    rev = version;
    hash = "sha256-03e8lScd220pgiTtIGkP7fOIcJhygQLwUkJ90fZv1Ok=";
  };

  sourceRoot = "source/packages/envd";
  vendorHash = "sha256-Qd737wtqIf9WFstG0uotFkhhQ9vgqaLR5xkUbZhHgFM=";

  env.GOWORK = "off";

  ldflags = [
    "-X=main.commitSHA=${version}"
    "-s"
    "-w"
  ];

  doCheck = false;

  postInstall = ''
    $out/bin/envd -version >/dev/null
    $out/bin/envd -commit >/dev/null
  '';

  meta = {
    description = "E2B envd daemon for CubeSandbox/E2B-compatible sandboxes";
    homepage = "https://github.com/e2b-dev/infra/tree/${version}/packages/envd";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "envd";
  };
}
