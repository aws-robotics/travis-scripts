#!/bin/bash
set -e

if [ ! -z "${TRAVIS_TAG}" ]; then
    # Do not run for builds triggered by tagging.
    echo "Skipping $0 $@"
    exit 0
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# create a shared mount point to put coverage report
mkdir shared/
# move travis scripts to share mount so they can be executed within the docker container
cp -r "${SCRIPT_DIR}" shared/
if [ -z "${SA_NAME}" ];
then
  # SA_NAME not set - assume a Cloud Extension build
  BUILD_SCRIPT_NAME=ros"$ROS_VERSION"_build.sh
else
  # SA_NAME is set - assume a Sample Application build
  BUILD_SCRIPT_NAME=ros"$ROS_VERSION"_sa_build.sh
fi

echo "using Build script, ${BUILD_SCRIPT_NAME}"
DOCKER_BUILD_SCRIPT="/shared/$(basename ${SCRIPT_DIR})/${BUILD_SCRIPT_NAME}"
# get a docker container from OSRF's docker hub
docker pull "ros:${ROS_DISTRO}-ros-core"
# run docker container
docker run -v "${PWD}/shared:/shared" \
  -e ROS_DISTRO="${ROS_DISTRO}" \
  -e PACKAGE_NAMES="${PACKAGE_NAMES}" \
  -e ROS_VERSION="${ROS_VERSION}" \
  -e NO_TEST="${NO_TEST}" \
  -e TRAVIS_BUILD_DIR="${TRAVIS_BUILD_DIR}" \
  -e $TRAVIS_BRANCH="${TRAVIS_BRANCH}" \
  -e PACKAGE_LANG="${PACKAGE_LANG:-cpp}" \
  -e GAZEBO_VERSION="${GAZEBO_VERSION:-7}" \
  -e DOCKER_BUILD_SCRIPT="${DOCKER_BUILD_SCRIPT}" \
  -e WORKSPACES="${WORKSPACES}" \
  --name "${ROS_DISTRO}-container" \
  --network=host \
  -dit "ros:${ROS_DISTRO}-ros-core" /bin/bash
# make a workspace in the docker container
docker exec "${ROS_DISTRO}-container" /bin/bash -c 'mkdir -p "/${ROS_DISTRO}_ws/src"'
# copy the code over to the docker container
docker cp "${TRAVIS_BUILD_DIR}" "${ROS_DISTRO}-container":"/${ROS_DISTRO}_ws/src/"
# execute build scripts and run test

docker exec "${ROS_DISTRO}"-container /bin/bash "${DOCKER_BUILD_SCRIPT}"
# upload coverage report to codecov
if [ -z "${NO_TEST}" ];
then
  bash <(curl -s https://codecov.io/bash) -Z -F "${ROS_DISTRO},ROS_${ROS_VERSION}"
fi
