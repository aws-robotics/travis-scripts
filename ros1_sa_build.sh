#!/bin/bash
set -e

env
bash -c "echo '`env | grep TRAVIS`'"

# install dependencies
apt update && apt install -y python3-pip python3-apt dpkg ros-$ROS_DISTRO-ros-base && rosdep update
apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools
pip3 install colcon-bundle colcon-ros-bundle
. /opt/ros/$ROS_DISTRO/setup.sh

ls /"$ROS_DISTRO"_ws/src
bash -c "echo '`ls /"$ROS_DISTRO"_ws/src 2>&1`'"
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
mv /"$ROS_DISTRO"_ws/src/$BUILD_DIR_NAME/robot_ws/bundle/robot.tar.gz /shared/robot.tar.gz
mv /"$ROS_DISTRO"_ws/src/$BUILD_DIR_NAME/simulation_ws/bundle/simulation.tar.gz /shared/simulation.tar.gz
