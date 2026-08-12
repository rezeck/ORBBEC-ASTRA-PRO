#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

xhost +local:docker >/dev/null 2>&1 || true

# OrbbecViewer holds the USB device exclusively
pkill -f '[Oo]rbbecViewer' >/dev/null 2>&1 || true

echo "[preview] building image (first run) + starting stack..."
docker compose up --build "$@"
