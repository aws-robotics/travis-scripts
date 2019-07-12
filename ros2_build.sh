#!/bin/bash
set -xe

# install dependencies
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 421C365BD9FF1F717815A3895523BAEEB01FA116
echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -sc` main" > /etc/apt/sources.list.d/ros-latest.list
apt update && apt install -y python3 python3-pip lcov cmake && rosdep update
apt update && apt install -y python3-rosinstall python3-colcon-common-extensions && pip3 install -U setuptools

REPO_NAME=$(basename -- ${TRAVIS_BUILD_DIR})
echo "repo: ${REPO_NAME} branch: ${TRAVIS_BRANCH}"

# use colcon as build tool to build the package, and optionally build tests
. "/opt/ros/${ROS_DISTRO}/setup.sh"
cd "/${ROS_DISTRO}_ws/"
if [ "${TRAVIS_BRANCH}" == "master" ] && [ -f "./src/${REPO_NAME}/.rosinstall.master" ]; then
    mkdir dep
    cd "/${ROS_DISTRO}_ws/dep"
    ln -s "../src/${REPO_NAME}/.rosinstall.master" .rosinstall
    rosws update
    cd "/${ROS_DISTRO}_ws/"
    rosdep install --from-paths src dep --ignore-src --rosdistro "${ROS_DISTRO}" -r -y
else
    rosdep install --from-paths src --ignore-src --rosdistro "${ROS_DISTRO}" -r -y
fi

colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-fprofile-arcs -ftest-coverage' -DCMAKE_C_FLAGS='-fprofile-arcs -ftest-coverage'

if [ -z "${NO_TEST}" ]; then
    if [ ! -z "${PACKAGE_NAMES}" ] && [ "${ROS_VERSION}" == "1" ]; then
        colcon build --packages-select ${PACKAGE_NAMES} --cmake-target tests
    fi

    # run unit tests
    . ./install/setup.sh
    colcon test
    colcon test-result --all

    # get unit test code coverage result
    lcov --capture --directory . --output-file coverage.info
    lcov --remove coverage.info '/usr/*' --output-file coverage.info
    lcov --list coverage.info
    cd "/${ROS_DISTRO}_ws/"
    mv coverage.info /shared
fi
