{ pkgs }:

# Evaluation-safe envd placeholder.
#
# The E2B/Cube contract requires /usr/bin/envd to implement at least:
#   - GET :49983/health -> 204
#   - POST :49983/process
#   - POST :49983/files
#   - POST :49983/init
#
# This placeholder is intentionally NOT a real envd. It exists so the flake
# can evaluate on machines where we do not want to fetch/build e2b-dev/infra.
# Downstream users should pass `envdPackage = <real envd derivation>` to
# mkE2BImage/mkE2BImageFromModule.
pkgs.writeShellScriptBin "envd" ''
  echo "This is an evaluation-only placeholder. Provide a real envdPackage." >&2
  exit 127
''
