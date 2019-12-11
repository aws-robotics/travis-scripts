# Travis Scripts

## Overview
This repository contains scripts used in Travis CIs for [AWS RoboMaker] sample applications and [AWS RoboMaker] ROS Cloud Extensions.

## Configuration Options

Configuration is done via environment variables. When adding a new option, make sure to also pass that variable into the docker container used for the build (see `ce_build.sh`).

### Common

* `ROS_VERSION`, `ROS_DISTRO`, `GAZEBO_VERSION`: determine which build flavour and docker image to use

### Sample Applications

* `WORKSPACES`: which workspaces should be built.
* `SOURCE_ONLY_WORKSPACES`: workspaces which shouldn't be be built, but the source files will be included in the source upload
* `SA_PACKAGE_NAME`: controls which package's manifest file would determine the version of the application bundle that's going to be uploaded to S3.
* `UPLOAD_SOURCES`: by default, the source files for `${WORKSPACES}` will be uploaded (along with LICENSE, NOTICE, README and roboMakerSettings.json files). You may override the default behavior.
  * `UPLOAD_SOURCES=false`: Skip source upload
  * Note: when workspaces are built separately (i.e. one build job for each workspace), it is recommended to disable source upload for the build jobs and add a dedicated stage for it using `prepare_sources_to_upload.sh`.

### Cloud Extensions

* `NO_TEST`: unit tests are enabled by default, specify NO_TESTS=true to override.

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
