#!/bin/bash
set -e

SCRIPT_DIR=$(dirname ${DOCKER_BUILD_SCRIPT})

# install dependencies
apt update && apt install -y python3-pip python3-apt dpkg ros-$ROS_DISTRO-ros-base && rosdep update
apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools
pip3 install colcon-bundle colcon-ros-bundle
. /opt/ros/$ROS_DISTRO/setup.sh

BUILD_DIR_NAME=`basename $TRAVIS_BUILD_DIR`

if [ -z "$WORKSPACES" ]; then
  WORKSPACES="robot_ws simulation_ws"
fi

for WS in $WORKSPACES
do
  # use colcon as build tool to build the workspace if it exists
  WS_DIR="/${ROS_DISTRO}_ws/src/${BUILD_DIR_NAME}/${WS}"
  echo "looking for ${WS}, $WS_DIR"
  if [ -d "${WS_DIR}" ]; then
    echo "WS ${WS_DIR} found, attempting to build"
    WS_BUILD_SCRIPT="/shared/$(basename ${SCRIPT_DIR})/ws_builds/${WS}.sh"
    if [ -f "${WS_BUILD_SCRIPT}" ]; then
      cd "${WS_DIR}"
      bash "${WS_BUILD_SCRIPT}"
      mv ./bundle/output.tar.gz /shared/"${WS}".tar.gz
    else
      echo "Unable to find build script ${WS_BUILD_SCRIPT}, build failed"
      exit 1
    fi
  else
    echo "Unable to find workspace ${WS_DIR}, build failed"
    exit 1
  fi
done
