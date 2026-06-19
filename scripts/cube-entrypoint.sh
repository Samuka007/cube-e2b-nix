#!/usr/bin/env bash
set -euo pipefail

ENVD_BIN="${ENVD_BIN:-/usr/bin/envd}"
ENVD_PORT="${ENVD_PORT:-49983}"
ENVD_LOG_FILE="${ENVD_LOG_FILE:-/var/log/envd.log}"
ENVD_EXTRA_ARGS="${ENVD_EXTRA_ARGS:-}"

mkdir -p /var/log /home/user /workspace /tmp
chmod 1777 /tmp || true

if [ "${ENVD_LOG_FILE}" = "-" ]; then
  "${ENVD_BIN}" -port "${ENVD_PORT}" ${ENVD_EXTRA_ARGS} &
else
  "${ENVD_BIN}" -port "${ENVD_PORT}" ${ENVD_EXTRA_ARGS} >"${ENVD_LOG_FILE}" 2>&1 &
fi

envd_pid="$!"

if [ "$#" -gt 0 ]; then
  exec "$@"
else
  wait "${envd_pid}"
fi
