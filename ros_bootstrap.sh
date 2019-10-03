#!/bin/bash
# Set up ROS APT and install basic dependencies (rosdep, rosinstall). Must have ROS_VERSION set when called.
set -xe

apt-get update && apt-get install -q -y dirmngr curl gnupg2 lsb-release zip python3-pip python3-apt dpkg
pip3 install -U setuptools

if [ "${ROS_VERSION}" == "1" ]; then
  sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
  apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
  apt-get update && apt-get install -y python-rosdep python-rosinstall
elif [ "${ROS_VERSION}" == "2" ]; then
  curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
  sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'
  apt-get update && apt-get install -y python3-rosdep python3-rosinstall
else
  echo "ROS_VERSION not defined or recognized"
  exit 1
fi
