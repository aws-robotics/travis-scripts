#!/bin/bash
set -xe

rosws update
GAZEBO_POST_ROSDEP_INSTALL_SCRIPT="${SCRIPT_DIR}/gazebo/${ROS_DISTRO}-gazebo${GAZEBO_VERSION}/post_rosdep_install.sh"
if [ -f ${GAZEBO_POST_ROSDEP_INSTALL_SCRIPT} ]; then
    "${GAZEBO_POST_ROSDEP_INSTALL_SCRIPT}"
fi

rosdep install --from-paths src --ignore-src -r -y

colcon build --build-base build --install-base install

# bundle will fail without this key
apt-key adv --fetch-keys http://packages.osrfoundation.org/gazebo.key
colcon bundle --build-base build --install-base install --bundle-base bundle
