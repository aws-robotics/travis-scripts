#!/bin/bash
set -xe

export SCRIPT_DIR=$(dirname ${DOCKER_BUILD_SCRIPT})

# install dependencies
ROS_BOOTSTRAP_SCRIPT=${SCRIPT_DIR}/ros_bootstrap.sh
"${ROS_BOOTSTRAP_SCRIPT}"
sudo apt-get update && sudo apt-get install --no-install-recommends -y python3-colcon-common-extensions ros-${ROS_DISTRO}-ros-base
sudo -H pip3 install -U colcon-bundle colcon-ros-bundle
# colcon-bundle setup requirements reinstalls the latest version(50.0.0) of setuptools.
# pin the latest tested version (49.3.0)
sudo -H pip3 install -U setuptools==49.3.0 --force-reinstall

COMMON_SA_BUILD_SCRIPT=${SCRIPT_DIR}/common_sa_build.sh
. "${COMMON_SA_BUILD_SCRIPT}"
