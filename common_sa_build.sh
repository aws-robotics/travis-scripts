#!/bin/bash
set -xe

export SCRIPT_DIR=$(dirname ${DOCKER_BUILD_SCRIPT})

# Remove the old rosdep sources.list
sudo rm -rf /etc/ros/rosdep/sources.list.d/*
sudo rosdep init && rosdep update

. /opt/ros/$ROS_DISTRO/setup.sh

BUILD_DIR_NAME=`basename ${TRAVIS_BUILD_DIR}`

if [ -z "$WORKSPACES" ]; then
  WORKSPACES="robot_ws simulation_ws"
fi

SOURCE_WORKSPACES="${WORKSPACES} ${SOURCE_ONLY_WORKSPACES}"

# Run ROSWS update in each workspace before creating archive
for WS in $SOURCE_WORKSPACES
do
  WS_DIR="/${ROS_DISTRO}_ws/src/${BUILD_DIR_NAME}/${WS}"
  echo "looking for ${WS}, $WS_DIR"
  if [ -d "${WS_DIR}" ]; then
    echo "WS ${WS_DIR} found, running rosws update"
    rosws update -t "${WS_DIR}"
  fi
done

# Create archive of relevant source files (unless UPLOAD_SOURCES is false)
if [ ! -z "$UPLOAD_SOURCES" ] && [ "$UPLOAD_SOURCES" == "false" ]; then
  echo "Skipping source upload for this build job"
else
  SOURCES_INCLUDES="${SOURCE_WORKSPACES} LICENSE* NOTICE* README* roboMakerSettings.json"
  cd /${ROS_DISTRO}_ws/src/${BUILD_DIR_NAME}/
  sudo /usr/bin/zip -r /shared/sources.zip $SOURCES_INCLUDES
  sudo tar cvzf /shared/sources.tar.gz $SOURCES_INCLUDES
fi

for WS in $WORKSPACES
do
  # use colcon as build tool to build the workspace if it exists
  WS_DIR="/${ROS_DISTRO}_ws/src/${BUILD_DIR_NAME}/${WS}"
  WS_BUILD_SCRIPT="/shared/$(basename ${SCRIPT_DIR})/ws_builds/${WS}.sh"
  if [ -f "${WS_BUILD_SCRIPT}" ]; then
    cd "${WS_DIR}"
    bash "${WS_BUILD_SCRIPT}"
    sudo mv ./bundle/output.tar /shared/"${WS}".tar
  else
    echo "Unable to find build script ${WS_BUILD_SCRIPT}, build failed"
    exit 1
  fi
done
