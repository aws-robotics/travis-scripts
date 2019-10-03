#!/bin/bash
set -xe

export SCRIPT_DIR=$(dirname ${DOCKER_BUILD_SCRIPT})

# install dependencies
apt-get update && apt-get install -q -y dirmngr gnupg2 lsb-release zip python3-pip python3-apt dpkg
pip3 install -U setuptools
sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
apt-get update && apt-get install --no-install-recommends -y python-rosdep python-rosinstall python3-colcon-common-extensions ros-$ROS_DISTRO-ros-base
pip3 install colcon-bundle colcon-ros-bundle

COMMON_SA_BUILD_SCRIPT=${SCRIPT_DIR}/common_sa_build.sh
"${COMMON_SA_BUILD_SCRIPT}"
