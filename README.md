# cube-e2b-nix

Nix-first packaging sketch for **E2B/CubeSandbox-compatible OCI images**.

The goal is not to wrap Dockerfile syntax. The goal is to make a sandbox image a Nix value:

```nix
cube.e2b = {
  name = "cube-e2b-data";
  packages = pkgs: with pkgs; [ python312 duckdb jq ];
  env.PYTHONUNBUFFERED = "1";
  ports = [ 8888 ];
};
```

Then the library turns it into a `dockerTools.buildLayeredImage` derivation.

## Shape

- `lib.mkE2BImage`: direct function API.
- `lib.mkE2BImageFromModule`: module-style API for downstream flakes.
- `lib.mkMinimalImage`: minimal E2B-compatible image skeleton.
- `pkgs/envd-placeholder.nix`: eval-only placeholder for `/usr/bin/envd`.
- `pkgs/envd-e2b.nix`: template for a real `buildGoModule` envd derivation.

## Docker/Nix best-practice choices used here

Based on nixpkgs `dockerTools` docs/examples:

1. Use `dockerTools.buildLayeredImage`, not an imperative Dockerfile build.
2. Put Nix package closures in `contents` via `pkgs.buildEnv`, so store paths layer cleanly and can be shared.
3. Add tiny rootfs metadata through `extraCommands`:
   - `/etc/passwd`, `/etc/group`, `/etc/hosts`
   - `/usr/bin/envd`
   - `/usr/local/bin/cube-entrypoint.sh`
4. Use `dockerTools.binSh` and `dockerTools.usrBinEnv` so `/bin/sh` and `/usr/bin/env` exist in scratch-style images.
5. Use `fakeRootCommands` for ownership/chown instead of needing privileged builds.
6. Put runtime metadata in OCI `config`: `Entrypoint`, `Env`, `WorkingDir`, `ExposedPorts`, labels.
7. Keep `/usr/bin/envd` injectable as `envdPackage`; this lets the image API evaluate without fetching/building E2B infra.

## Important limitation

The checked-in `envd-placeholder` is **not a real envd**. It exists only so `nix eval` can validate the image graph on a low-disk machine.

For a working Cube/E2B image, pass a real envd derivation:

```nix
let
  realEnvd = pkgs.callPackage ./pkgs/envd-e2b.nix {
    srcHash = "sha256-...";
    vendorHash = "sha256-...";
  } {};
in e2b.mkE2BImageFromModule {
  cube.e2b = {
    name = "cube-e2b-real";
    envdPackage = realEnvd;
    packages = pkgs: with pkgs; [ python312 jq ];
  };
}
```

## Eval-only validation

These are safe on a low-disk host. They evaluate the flake and derivations but do not create/load the Docker image tarball:

```bash
nix flake show --no-write-lock-file
nix eval .#packages.x86_64-linux.minimalImage.imageName --raw
nix eval .#packages.x86_64-linux.minimalImage.imageTag --raw
```

Do **not** run this on a constrained host unless you intend to build the image tarball:

```bash
nix build .#packages.x86_64-linux.minimalImage
```
