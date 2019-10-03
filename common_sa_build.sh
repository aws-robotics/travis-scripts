#!/bin/bash
set -xe

export SCRIPT_DIR=$(dirname ${DOCKER_BUILD_SCRIPT})

# Remove the old rosdep sources.list
rm -rf /etc/ros/rosdep/sources.list.d/*
rosdep init && rosdep update

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

# Create archive of relevant sources files (unless UPLOAD_SOURCES is false)
if [ ! -z "$UPLOAD_SOURCES" ] && [ "$UPLOAD_SOURCES" == "false" ]; then
  echo "Skipping source upload for this build job"
else
  if [ -z "$UPLOAD_SOURCES" ]; then
    SOURCES_INCLUDES="${WORKSPACES} LICENSE* NOTICE* README* roboMakerSettings.json"
    echo "Using default source upload: ${SOURCES_INCLUDES}"
  else
    SOURCES_INCLUDES=${UPLOAD_SOURCES}
    echo "Override set for source upload: ${SOURCES_INCLUDES}"
  fi
  cd /${ROS_DISTRO}_ws/src/${BUILD_DIR_NAME}/
  /usr/bin/zip -r /shared/sources.zip $SOURCES_INCLUDES
  tar cvzf /shared/sources.tar.gz $SOURCES_INCLUDES
fi

for WS in $WORKSPACES
do
  # use colcon as build tool to build the workspace if it exists
  WS_DIR="/${ROS_DISTRO}_ws/src/${BUILD_DIR_NAME}/${WS}"
  WS_BUILD_SCRIPT="/shared/$(basename ${SCRIPT_DIR})/ws_builds/${WS}.sh"
  if [ -f "${WS_BUILD_SCRIPT}" ]; then
    cd "${WS_DIR}"
    bash "${WS_BUILD_SCRIPT}"
    mv ./bundle/output.tar /shared/"${WS}".tar
  else
    echo "Unable to find build script ${WS_BUILD_SCRIPT}, build failed"
    exit 1
  fi
done
