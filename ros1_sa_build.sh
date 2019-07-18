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

# Get latest colcon bundle
COLCON_BUNDLE_INSTALL_PATH="${HOME}/colcon-bundle"
rm -rf "${COLCON_BUNDLE_INSTALL_PATH}"
git clone https://github.com/colcon/colcon-bundle "${COLCON_BUNDLE_INSTALL_PATH}"

# Switch to commit "Support Melodic, fix aptitude trusted key config"
#  https://github.com/colcon/colcon-bundle/commit/d5ea60e1a9adb34c5ba96e0fbd32fcd188cde15a
WORKING_DIRECTORY=${PWD}
cd ${COLCON_BUNDLE_INSTALL_PATH}
git checkout d5ea60e1a9adb34c5ba96e0fbd32fcd188cde15a
cd ${WORKING_DIRECTORY}

pip3 install --upgrade pip
pip install -U --editable "${COLCON_BUNDLE_INSTALL_PATH}"

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
    "${WS_BUILD_SCRIPT}"
    mv ./bundle/output.tar /shared/"${WS}".tar
  else
    echo "Unable to find build script ${WS_BUILD_SCRIPT}, build failed"
    exit 1
  fi
done
