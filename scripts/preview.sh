#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

IMAGE="${ASTRA_PREVIEW_IMAGE:-osrf/ros:noetic-desktop-full}"
CONTAINER="${ASTRA_CONTAINER_NAME:-astra-pro-preview}"

xhost +local:docker >/dev/null 2>&1 || true

# OrbbecViewer holds the USB device exclusively
pkill -f '[Oo]rbbecViewer' >/dev/null 2>&1 || true

if ! docker inspect "${CONTAINER}" >/dev/null 2>&1; then
  docker run --rm -d \
    --name "${CONTAINER}" \
    --privileged \
    --network host \
    --ipc host \
    -e DISPLAY="${DISPLAY:-:0}" \
    -e QT_X11_NO_MITSHM=1 \
    -e ROS_MASTER_URI=http://127.0.0.1:11311 \
    -e ROS_HOSTNAME=127.0.0.1 \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v "${XAUTHORITY:-$HOME/.Xauthority}:/root/.Xauthority:rw" \
    -v "${ROOT_DIR}:/workspace" \
    -v /dev:/dev \
    --gpus all \
    "${IMAGE}" \
    sleep infinity
else
  docker start "${CONTAINER}" >/dev/null
fi

# Seed RGB camera_info used when URI load fails / first boot
docker exec "${CONTAINER}" bash -lc '
  mkdir -p /root/.ros/camera_info
  cp -f /workspace/config/camera_info/rgb_camera.yaml /root/.ros/camera_info/rgb_camera.yaml
  cp -f /workspace/config/camera_info/rgb_camera.yaml /root/.ros/camera_info/camera.yaml
'

echo "[preview] ensuring deps + building workspace..."
docker exec "${CONTAINER}" bash -lc '
  set -e
  export DEBIAN_FRONTEND=noninteractive
  source /opt/ros/noetic/setup.bash
  if ! dpkg -s libgflags-dev >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends \
      build-essential cmake git pkg-config python3-numpy \
      libusb-1.0-0-dev libgflags-dev libdw-dev libeigen3-dev \
      ros-noetic-image-geometry ros-noetic-camera-info-manager \
      ros-noetic-image-transport ros-noetic-image-publisher \
      ros-noetic-backward-ros
  fi
  if [[ ! -f /usr/local/lib/libuvc.so && ! -f /usr/local/lib/libuvc.a ]]; then
    rm -rf /tmp/libuvc
    git clone --depth 1 https://github.com/libuvc/libuvc.git /tmp/libuvc
    cmake -S /tmp/libuvc -B /tmp/libuvc/build -DCMAKE_BUILD_TYPE=Release
    cmake --build /tmp/libuvc/build -j"$(nproc)"
    cmake --install /tmp/libuvc/build
    ldconfig
  fi
  cd /workspace/orbbec_ws
  catkin_make -DCATKIN_WHITELIST_PACKAGES="astra_camera;astra_pro_bringup" -j"$(nproc)"
'

echo "[preview] launching Astra Pro (cloud + IR + RGB)..."
exec docker exec -e DISPLAY="${DISPLAY:-:0}" -it "${CONTAINER}" bash -lc '
  set -e
  source /opt/ros/noetic/setup.bash
  source /workspace/orbbec_ws/devel/setup.bash
  roslaunch astra_pro_bringup astra_pro_preview.launch
'
