#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RULES_SRC="${ROOT_DIR}/config/udev/56-orbbec-usb.rules"
if [[ ! -f "${RULES_SRC}" ]]; then
  echo "Missing ${RULES_SRC}" >&2
  exit 1
fi

echo "[setup] installing Orbbec udev rules..."
sudo cp "${RULES_SRC}" /etc/udev/rules.d/56-orbbec-usb.rules
sudo udevadm control --reload-rules
sudo udevadm trigger

if ! id -nG "$USER" | grep -qw video; then
  echo "[setup] adding ${USER} to group video (re-login required)..."
  sudo usermod -aG video "$USER"
fi

echo "[setup] done. Unplug/replug the Astra Pro USB cable."
lsusb | grep -i 2bc5 || echo "Camera not detected yet (plug it in)."
