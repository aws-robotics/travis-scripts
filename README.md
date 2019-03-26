# Travis Scripts

## Overview
This repository contains scripts used in Travis CIs for [AWS RoboMaker] sample applications and [AWS RoboMaker] ROS Cloud Extensions.

## Testing locally

### Testing Sample Applications

For example for testing `aws-robomaker-sample-application-helloworld`. Assuming a Docker container running with `/opt/workspace` mounting a host directory that contains a `src` directory where `aws-robomaker-sample-application-helloworld` and `travis-scripts` are cloned. Run the following commands on the container:

```bash
ln -s /opt/workspace "/${ROS_DISTRO}_ws"
mkdir -p /shared

# Travis build matrix env vars
export ROS_DISTRO=kinetic
export GAZEBO_VERSION=9
# Sample app to build
export TRAVIS_BUILD_DIR=aws-robomaker-sample-application-helloworld

function cleanup_artifacts {
  for ws in robot_ws simulation_ws
  do
    for dir in build bundle install
    do
      rm -rf "/opt/workspace/src/${TRAVIS_BUILD_DIR}/${ws}/${dir}"
    done
  done
  rm -rf /shared/*
}
cleanup_artifacts && bash -x ros1_sa_build.sh &> sa_build.log
```

## License

This library is licensed under the Apache 2.0 License. 

[AWS RoboMaker]: https://github.com/aws-robotics