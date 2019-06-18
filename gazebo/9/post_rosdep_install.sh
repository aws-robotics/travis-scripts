#!/bin/bash

# Install Gazebo 9, and remove gazebo 7
set -e

echo "Setting up Gazebo 9"

apt-get install wget -y
echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list
wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add -
apt-get update

G9_APT_FILE="/etc/ros/rosdep/sources.list.d/00-gazebo9.list"
rm -f "${G9_APT_FILE}"
touch "${G9_APT_FILE}"
echo "yaml https://github.com/osrf/osrf-rosdep/raw/master/gazebo9/gazebo.yaml" >> "${G9_APT_FILE}"
echo "yaml https://github.com/osrf/osrf-rosdep/raw/master/gazebo9/releases/indigo.yaml indigo" >> "${G9_APT_FILE}"
echo "yaml https://github.com/osrf/osrf-rosdep/raw/master/gazebo9/releases/jade.yaml jade" >> "${G9_APT_FILE}"
echo "yaml https://github.com/osrf/osrf-rosdep/raw/master/gazebo9/releases/kinetic.yaml kinetic" >> "${G9_APT_FILE}"
echo "yaml https://github.com/osrf/osrf-rosdep/raw/master/gazebo9/releases/lunar.yaml lunar" >> "${G9_APT_FILE}"

apt-get update

echo "Uninstalling Gazebo 7"
apt-get remove --purge *gazebo7* -y
apt-get remove ros-kinetic-gazebo* -y
apt-get remove libgazebo* -y
apt-get remove gazebo* -y
echo "Gazebo 7 uninstalled with success"

echo "Installing Gazebo 9"
apt-get install ros-kinetic-gazebo9-* -y
echo "Gazebo 9 installed with success"

echo "Gazebo 9 setup completed with success"
