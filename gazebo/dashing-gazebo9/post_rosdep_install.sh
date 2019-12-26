#!/bin/bash
set -e

# Only set up Gazebo's repository
echo "Setting up Gazebo repository"

sudo apt-get install -y wget
echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list
wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
sudo apt-get update
