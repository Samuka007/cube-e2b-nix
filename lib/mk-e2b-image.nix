{ lib, pkgs }:

{ name
, tag ? "latest"
, envdPackage ? pkgs.callPackage ../pkgs/envd-placeholder.nix {}
, packages ? (_pkgs: [])
, extraEnv ? {}
, workingDir ? "/home/user"
, cmd ? []
, extraPorts ? []
, enableSudo ? true
, userName ? "user"
, uid ? 1000
, gid ? 1000
, maxLayers ? 100
}:

let
  basePackages = with pkgs; [
    bashInteractive
    coreutils
    findutils
    gnugrep
    gnused
    gawk
    curl
    cacert
    git
    jq
    ripgrep
    procps
  ] ++ lib.optionals enableSudo [ sudo ];

  userPackages = packages pkgs;

  envRoot = pkgs.buildEnv {
    name = "${name}-env";
    paths = basePackages ++ userPackages;
    pathsToLink = [ "/bin" "/share" "/etc" ];
  };

  cubeEntrypoint = pkgs.writeShellScriptBin "cube-entrypoint.sh"
    (builtins.readFile ../scripts/cube-entrypoint.sh);

  defaultEnv = {
    ENVD_PORT = "49983";
    ENVD_BIN = "/usr/bin/envd";
    ENVD_LOG_FILE = "/var/log/envd.log";
    HOME = "/home/${userName}";
    USER = userName;
    LANG = "C.UTF-8";
    LC_ALL = "C.UTF-8";
    PATH = "${envRoot}/bin:/usr/bin:/bin:/usr/local/bin";
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  envList = lib.mapAttrsToList (k: v: "${k}=${toString v}") (defaultEnv // extraEnv);

  exposedPorts = lib.unique ([ 49983 ] ++ extraPorts);
  exposedPortsAttrs = lib.listToAttrs (map (port: {
    name = "${toString port}/tcp";
    value = {};
  }) exposedPorts);

in
pkgs.dockerTools.buildLayeredImage {
  inherit name tag maxLayers;

  contents = [
    envRoot
    pkgs.dockerTools.caCertificates
    pkgs.dockerTools.binSh
    pkgs.dockerTools.usrBinEnv
  ];

  # Best-practice split:
  # - contents carries Nix closures as shareable layers.
  # - extraCommands adds small rootfs metadata files.
  # - fakeRootCommands sets ownership without requiring privileged builds.
  extraCommands = ''
    mkdir -p usr/bin usr/local/bin etc etc/sudoers.d home/${userName} workspace tmp var/log root
    chmod 1777 tmp

    cp ${envdPackage}/bin/envd usr/bin/envd
    chmod +x usr/bin/envd

    cp ${cubeEntrypoint}/bin/cube-entrypoint.sh usr/local/bin/cube-entrypoint.sh
    chmod +x usr/local/bin/cube-entrypoint.sh

    cat > etc/passwd <<'EOF'
root:x:0:0:root:/root:/bin/sh
${userName}:x:${toString uid}:${toString gid}:${userName}:/home/${userName}:/bin/sh
EOF

    cat > etc/group <<'EOF'
root:x:0:
${userName}:x:${toString gid}:
EOF

    cat > etc/hosts <<'EOF'
127.0.0.1 localhost
::1 localhost
EOF

    ${lib.optionalString enableSudo ''
      echo '${userName} ALL=(ALL) NOPASSWD:ALL' > etc/sudoers.d/${userName}
      chmod 0440 etc/sudoers.d/${userName}
    ''}
  '';

  fakeRootCommands = ''
    chown -R ${toString uid}:${toString gid} ./home/${userName} ./workspace || true
    chmod 0755 ./home/${userName} ./workspace || true
  '';

  config = {
    Entrypoint = [ "/usr/local/bin/cube-entrypoint.sh" ];
    Cmd = cmd;
    WorkingDir = workingDir;
    Env = envList;
    ExposedPorts = exposedPortsAttrs;
    User = "0:0";
    Labels = {
      "org.opencontainers.image.title" = name;
      "io.cubesandbox.envd.port" = "49983";
      "io.cubesandbox.envd.contract" = "e2b-envd";
    };
  };
}
