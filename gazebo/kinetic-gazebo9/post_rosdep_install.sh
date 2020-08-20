#!/bin/bash
set -e

# Remove Kinetic Gazebo 7 and Install Kinetic Gazebo 9
echo "Setting up Gazebo 9"

sudo apt-get install -y wget
echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list
wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
sudo apt-get update

G9_APT_FILE="/etc/ros/rosdep/sources.list.d/00-gazebo9.list"
sudo rm -f "${G9_APT_FILE}"
sudo touch "${G9_APT_FILE}"
echo "yaml https://github.com/osrf/osrf-rosdep/raw/master/gazebo9/gazebo.yaml" | sudo tee -a "${G9_APT_FILE}"
echo "yaml https://github.com/osrf/osrf-rosdep/raw/master/gazebo9/releases/indigo.yaml indigo" | sudo tee -a "${G9_APT_FILE}"
echo "yaml https://github.com/osrf/osrf-rosdep/raw/master/gazebo9/releases/jade.yaml jade" | sudo tee -a "${G9_APT_FILE}"
echo "yaml https://github.com/osrf/osrf-rosdep/raw/master/gazebo9/releases/kinetic.yaml kinetic" | sudo tee -a "${G9_APT_FILE}"
echo "yaml https://github.com/osrf/osrf-rosdep/raw/master/gazebo9/releases/lunar.yaml lunar" | sudo tee -a "${G9_APT_FILE}"

rosdep update
sudo apt-get update

echo "Uninstalling Gazebo 7"
sudo apt-get remove --purge -y *gazebo7*
sudo apt-get remove -y ros-kinetic-gazebo*
sudo apt-get remove -y libgazebo*
sudo apt-get remove -y gazebo*
echo "Gazebo 7 uninstalled with success"

echo "Installing Gazebo 9"
sudo apt-get install -y ros-kinetic-gazebo9-*

echo "Gazebo 9 installed with success"

echo "Gazebo 9 setup completed with success"
