#!/bin/bash
set -xe

export SCRIPT_DIR=$(dirname ${DOCKER_BUILD_SCRIPT})

# install dependencies
ROS_BOOTSTRAP_SCRIPT=${SCRIPT_DIR}/ros_bootstrap.sh
"${ROS_BOOTSTRAP_SCRIPT}"
sudo apt-get update && sudo apt-get install --no-install-recommends -y python3-colcon-common-extensions ros-${ROS_DISTRO}-ros-base
sudo -H pip3 install -U colcon-core==0.4.5
sudo -H pip3 install -U colcon-bundle colcon-ros-bundle

COMMON_SA_BUILD_SCRIPT=${SCRIPT_DIR}/common_sa_build.sh
. "${COMMON_SA_BUILD_SCRIPT}"
