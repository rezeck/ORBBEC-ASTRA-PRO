FROM osrf/ros:noetic-desktop-full

ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=noetic
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git pkg-config wget ca-certificates \
    python3-numpy \
    libusb-1.0-0-dev libgflags-dev libdw-dev libeigen3-dev \
    ros-${ROS_DISTRO}-image-geometry \
    ros-${ROS_DISTRO}-camera-info-manager \
    ros-${ROS_DISTRO}-image-transport \
    ros-${ROS_DISTRO}-image-publisher \
    ros-${ROS_DISTRO}-backward-ros \
    && rm -rf /var/lib/apt/lists/*

# libuvc for Astra Pro RGB (UVC)
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/libuvc/libuvc.git \
    && cmake -S libuvc -B libuvc/build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build libuvc/build -j"$(nproc)" \
    && cmake --install libuvc/build \
    && ldconfig \
    && rm -rf /tmp/libuvc

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /workspace
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
