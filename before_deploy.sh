#!/bin/bash
-e

export SA_VERSION=1
export CC_REPO_CLONE_URL_HTTP=`aws codecommit get-repository --repository-name AppManifest-"$SA_NAME"-"$ROS_DISTRO"-gazebo"$GAZEBO_VERSION" | jq -r '.repositoryMetadata | .cloneUrlHttp'`
