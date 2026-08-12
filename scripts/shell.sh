#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"
xhost +local:docker >/dev/null 2>&1 || true
docker compose --profile dev run --rm shell
