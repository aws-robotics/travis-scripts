#!/bin/bash
# This is a standalone script that is meant to be run from Travis directly, outside of a docker container.
set -xe
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Bootstrap to get basic ROS dependencies (rosinstall)
ROS_BOOTSTRAP_SCRIPT="${SCRIPT_DIR}/ros_bootstrap.sh"
sudo ROS_VERSION=${ROS_VERSION} "${ROS_BOOTSTRAP_SCRIPT}"

if [ -z "$WORKSPACES" ]; then
  WORKSPACES="robot_ws simulation_ws"
fi

for WS in ${WORKSPACES}
do
  WS_DIR="${TRAVIS_BUILD_DIR}/${WS}"
  echo "looking for ${WS}, ${WS_DIR}"
  if [ -d "${WS_DIR}" ]; then
    echo "WS ${WS_DIR} found, running rosws update"
    rosws update -t "${WS_DIR}"
  fi
done

SOURCES_INCLUDES="${WORKSPACES} LICENSE* NOTICE* README* roboMakerSettings.json"
mkdir shared 2>/dev/null
/usr/bin/zip -r shared/sources.zip $SOURCES_INCLUDES
tar cvzf shared/sources.tar.gz $SOURCES_INCLUDES
