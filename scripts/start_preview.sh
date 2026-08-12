#!/usr/bin/env bash
set -euo pipefail

cd /workspace

mkdir -p /root/.ros/camera_info
cp -f /workspace/config/camera_info/rgb_camera.yaml /root/.ros/camera_info/rgb_camera.yaml
cp -f /workspace/config/camera_info/rgb_camera.yaml /root/.ros/camera_info/camera.yaml

source /opt/ros/noetic/setup.bash

if [[ ! -f /workspace/orbbec_ws/devel/lib/astra_camera/astra_camera_node ]]; then
  echo "[start] building astra_camera + astra_pro_bringup..."
  cd /workspace/orbbec_ws
  catkin_make -DCATKIN_WHITELIST_PACKAGES="astra_camera;astra_pro_bringup" -j"$(nproc)"
fi

# shellcheck disable=SC1091
source /workspace/orbbec_ws/devel/setup.bash

export QT_X11_NO_MITSHM=1
export OGRE_RTT_MODE=Copy
export __GL_SYNC_TO_VBLANK=0
export __GL_MaxFramesAllowed=1
export LIBGL_ALWAYS_SOFTWARE=1
export GALLIUM_DRIVER=llvmpipe
export QT_XCB_GL_INTEGRATION=xcb_egl

exec roslaunch astra_pro_bringup astra_pro_preview.launch
