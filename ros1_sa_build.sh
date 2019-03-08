#!/bin/bash
set -e

# install dependencies
apt update && apt install -y python3-pip python3-apt dpkg ros-$ROS_DISTRO-ros-base && rosdep update
apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools
pip3 install colcon-bundle colcon-ros-bundle
. /opt/ros/$ROS_DISTRO/setup.sh

BUILD_DIR_NAME=`basename $TRAVIS_BUILD_DIR`
# use colcon as build tool to build the robot workspace
cd /"$ROS_DISTRO"_ws/src/$BUILD_DIR_NAME/robot_ws/
rosws update
rosdep install --from-paths src --ignore-src -r -y
colcon build --build-base build --install-base install
colcon bundle --build-base build --install-base install --bundle-base bundle
mv ./bundle/output.tar.gz ./bundle/robot.tar.gz

# use colcon as build tool to build the simulation workspace
cd /"$ROS_DISTRO"_ws/src/$BUILD_DIR_NAME/simulation_ws/
rosws update
rosdep install --from-paths src --ignore-src -r -y
colcon build --build-base build --install-base install
colcon bundle --build-base build --install-base install --bundle-base bundle
mv ./bundle/output.tar.gz ./bundle/simulation.tar.gz

# move the artifacts to a shared mount point
mv /"$ROS_DISTRO"_ws/src/$BUILD_DIR_NAME/robot_ws/bundle/robot.tar.gz /shared/robot_ws.tar.gz
mv /"$ROS_DISTRO"_ws/src/$BUILD_DIR_NAME/simulation_ws/bundle/simulation.tar.gz /shared/simulation_ws.tar.gz
