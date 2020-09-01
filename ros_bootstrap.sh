#!/bin/bash
set -xe

# Set up ROS APT and install basic dependencies (rosdep, rosinstall). Must have ROS_VERSION set when called.
sudo apt-get update && sudo apt-get install -q -y dirmngr curl gnupg2 lsb-release zip python3-pip python3-apt dpkg
sudo -H pip3 install -U setuptools
# NOTE: Workaround for setuptools 50.0.* (see https://github.com/pypa/setuptools/issues/2352)
export SETUPTOOLS_USE_DISTUTILS=stdlib

if [ "${ROS_VERSION}" == "1" ]; then
  echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros-latest.list
  apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
  sudo apt-get update && sudo apt-get install -y python-rosdep python-rosinstall
elif [ "${ROS_VERSION}" == "2" ]; then
  curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
  echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/ros2-latest.list
  sudo apt-get update && sudo apt-get install -y python3-rosdep python3-rosinstall
else
  echo "ROS_VERSION not defined or recognized"
  exit 1
fi
