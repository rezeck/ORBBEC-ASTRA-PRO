#!/usr/bin/env bash
set -e
source /opt/ros/noetic/setup.bash
if [[ -f /workspace/orbbec_ws/devel/setup.bash ]]; then
  # shellcheck disable=SC1091
  source /workspace/orbbec_ws/devel/setup.bash
fi
exec "$@"
