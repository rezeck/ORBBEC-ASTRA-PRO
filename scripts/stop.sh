#!/usr/bin/env bash
set -euo pipefail
CONTAINER="${ASTRA_CONTAINER_NAME:-astra-pro-preview}"
docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
echo "[stop] container ${CONTAINER} removed"
