#!/bin/bash
set -e

SCRIPT_DIR=$(dirname ${DOCKER_BUILD_SCRIPT})

# install dependencies
apt update && apt install -y python3-pip python3-apt zip dpkg ros-$ROS_DISTRO-ros-base && rosdep update
apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools
pip3 install colcon-bundle colcon-ros-bundle
. /opt/ros/$ROS_DISTRO/setup.sh

# compress the source code to create artifacts
echo "compressing artifacts"
cd /"$ROS_DISTRO"_ws/
tar -zcvf sources.tar.gz "$SA_NAME"
zip -r sources.zip "$SA_NAME"
mv ./sources.tar.gz /shared/sources.tar.gz
mv ./sources.zip /shared/sources.zip

# use colcon as build tool to build the robot workspace
echo "building robot ws"
cd /"$ROS_DISTRO"_ws/"$SA_NAME"/robot_ws/

rosws update
rosdep install --from-paths src --ignore-src -r -y
colcon build --base-paths . --build-base /build/private/"$SA_NAME"/build-output --install-base ./build/private/"$SA_NAME"/install-output
colcon bundle --include-sources --base-paths . --build-base ./build/private/"$SA_NAME"/build-output --install-base ./build/private/"$SA_NAME"/install-output --bundle-base ./build/private/"$SA_NAME"/bundle-output
mv ./build/private/"$SA_NAME"/bundle-output/output.tar.gz ./build/private/"$SA_NAME"/bundle-output/robot_ws.tar.gz
mv ./build/private/"$SA_NAME"/bundle-output/sources.tar.gz ./build/private/"$SA_NAME"/bundle-output/robot_ws_dependency_sources.tar.gz

# use colcon as build tool to build the simulation workspace
echo "building simulation ws"
cd /"$ROS_DISTRO"_ws/"$SA_NAME"/simulation_ws/
rosws update
rosdep install --from-paths src --ignore-src -r -y
colcon build --base-paths . --build-base /build/private/"$SA_NAME"/build-output --install-base ./build/private/"$SA_NAME"/install-output
colcon bundle --include-sources --base-paths . --build-base ./build/private/"$SA_NAME"/build-output --install-base ./build/private/"$SA_NAME"/install-output --bundle-base ./build/private/"$SA_NAME"/bundle-output
mv ./build/private/"$SA_NAME"/bundle-output/output.tar.gz ./build/private/"$SA_NAME"/bundle-output/simulation_ws.tar.gz
mv ./build/private/"$SA_NAME"/bundle-output/sources.tar.gz ./build/private/"$SA_NAME"/bundle-output/simulation_ws_dependency_sources.tar.gz

# move the artifacts to a shared mount point
echo "moving artifacts to shared mount point"
mv /"$ROS_DISTRO"_ws/"$SA_NAME"/robot_ws/build/private/"$SA_NAME"/bundle-output/robot_ws.tar.gz /shared/robot_ws.tar.gz
mv /"$ROS_DISTRO"_ws/"$SA_NAME"/robot_ws/build/private/"$SA_NAME"/bundle-output/robot_ws_dependency_sources.tar.gz /shared/robot_ws_dependency_sources.tar.gz
mv /"$ROS_DISTRO"_ws/"$SA_NAME"/simulation_ws/build/private/"$SA_NAME"/bundle-output/simulation_ws.tar.gz /shared/simulation_ws.tar.gz
mv /"$ROS_DISTRO"_ws/"$SA_NAME"/simulation_ws/build/private/"$SA_NAME"/bundle-output/simulation_ws_dependency_sources.tar.gz /shared/simulation_ws_dependency_sources.tr.gz

