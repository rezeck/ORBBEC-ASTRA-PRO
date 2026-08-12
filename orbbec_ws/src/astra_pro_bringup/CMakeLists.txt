cmake_minimum_required(VERSION 3.0.2)
project(astra_pro_bringup)
find_package(catkin REQUIRED)
catkin_package()
install(DIRECTORY launch rviz config
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
catkin_install_python(PROGRAMS scripts/color_brighten.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
