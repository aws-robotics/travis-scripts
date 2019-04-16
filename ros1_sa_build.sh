#!/bin/bash
set -e

SCRIPT_DIR=$(dirname ${DOCKER_BUILD_SCRIPT})

# install dependencies
apt update && apt install -y zip python3-pip python3-apt dpkg ros-$ROS_DISTRO-ros-base && rosdep update
apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools
pip3 install colcon-bundle colcon-ros-bundle
. /opt/ros/$ROS_DISTRO/setup.sh

BUILD_DIR_NAME=`basename $TRAVIS_BUILD_DIR`

if [ -z "$WORKSPACES" ]; then
  WORKSPACES="robot_ws simulation_ws"
fi

# Run ROSWS update in each workspace before creating archive
for WS in $WORKSPACES
do
  WS_DIR="/${ROS_DISTRO}_ws/src/${BUILD_DIR_NAME}/${WS}"
  echo "looking for ${WS}, $WS_DIR"
  if [ -d "${WS_DIR}" ]; then
    echo "WS ${WS_DIR} found, running rosws update"
    rosws update -t "${WS_DIR}"
  fi
done

# Create archive of all sources files
SOURCES_INCLUDES="${WORKSPACES} LICENSE* NOTICE* README* roboMakerSettings.json"
cd /${ROS_DISTRO}_ws/src/${BUILD_DIR_NAME}/
/usr/bin/zip -r /shared/sources.zip $SOURCES_INCLUDES
tar cvzf /shared/sources.tar.gz $SOURCES_INCLUDES

for WS in $WORKSPACES
do
  # use colcon as build tool to build the workspace if it exists
  WS_DIR="/${ROS_DISTRO}_ws/src/${BUILD_DIR_NAME}/${WS}"
  WS_BUILD_SCRIPT="/shared/$(basename ${SCRIPT_DIR})/ws_builds/${WS}.sh"
  if [ -f "${WS_BUILD_SCRIPT}" ]; then
    cd "${WS_DIR}"
    bash "${WS_BUILD_SCRIPT}"
    mv ./bundle/output.tar /shared/"${WS}".tar
    mv ./bundle/dependencies.tar.gz /shared/${WS}_dependency_sources.tar.gz
  else
    echo "Unable to find build script ${WS_BUILD_SCRIPT}, build failed"
    exit 1
  fi
done
