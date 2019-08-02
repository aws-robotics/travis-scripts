#!/bin/bash

# Only set up Gazebo's repository
set -e

echo "Setting up Gazebo repository"

apt-get install wget -y
echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list
wget http://packages.osrfoundation.org/gazebo.key -O - | apt-key add -
apt-get update
