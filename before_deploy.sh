#!/bin/bash
set -e

if [ ! -z "${TRAVIS_TAG}" ]; then
    # Do not run for builds triggered by tagging.
    echo "Skipping $0 $@"
    exit 0
fi

# Fetch the relevant S3 bucket & CodePipeline
export S3_BUCKET_NAME=`aws s3 ls | grep "travis-source" | awk '{print $3}'`
export SA_NAME_WITHOUT_DASHES=`echo $SA_NAME | sed -e 's/-//g'`
export CC_REPO_CLONE_URL_HTTP=`aws codecommit get-repository --repository-name AppManifest-"$SA_NAME"-"$ROS_DISTRO"-gazebo"$GAZEBO_VERSION" | jq -r '.repositoryMetadata | .cloneUrlHttp'`
