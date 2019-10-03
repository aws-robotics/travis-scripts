#!/bin/bash
set -xe

export SCRIPT_DIR=$(dirname ${DOCKER_BUILD_SCRIPT})

# install dependencies
apt-get update && apt-get install -q -y dirmngr curl gnupg2 lsb-release zip python3-pip python3-apt dpkg
pip3 install -U setuptools

curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
apt-get update && apt-get install --no-install-recommends -y python3-rosdep python3-rosinstall python3-colcon-common-extensions ros-$ROS_DISTRO-ros-base
apt list --upgradable 2>/dev/null | awk {'print $1'} | sed 's/\/.*//g' | grep $ROS_DISTRO | xargs apt install -y
pip3 install colcon-bundle colcon-ros-bundle

# Get latest colcon bundle
COLCON_BUNDLE_INSTALL_PATH="${HOME}/colcon-bundle"
rm -rf "${COLCON_BUNDLE_INSTALL_PATH}"
COLCON_ROS_BUNDLE_INSTALL_PATH="${HOME}/colcon-ros-bundle"
rm -rf "${COLCON_ROS_BUNDLE_INSTALL_PATH}"
git clone https://github.com/colcon/colcon-bundle "${COLCON_BUNDLE_INSTALL_PATH}"
git clone https://github.com/colcon/colcon-ros-bundle "${COLCON_ROS_BUNDLE_INSTALL_PATH}"

pip3 install --upgrade pip
pip install -U --editable "${COLCON_BUNDLE_INSTALL_PATH}"
pip install -U --editable "${COLCON_ROS_BUNDLE_INSTALL_PATH}"

COMMON_SA_BUILD_SCRIPT=${SCRIPT_DIR}/common_sa_build.sh
. "${COMMON_SA_BUILD_SCRIPT}"
