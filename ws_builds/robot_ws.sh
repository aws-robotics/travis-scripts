#!/bin/bash
set -xe

rosws update
rosdep install --from-paths src --ignore-src -r -y

colcon build --build-base build --install-base install
colcon bundle --build-base build --install-base install --bundle-base bundle
