#!/bin/bash
set -e

if [ ! -z "${TRAVIS_TAG}" ]; then
    # Do not run for builds triggered by tagging.
    echo "Skipping $0 $@"
    exit 0
fi

# Move artifacts to shared/<version>/ and version.json to shared/
mkdir $SA_VERSION && mv $TRAVIS_BUILD_DIR/shared/* $SA_VERSION && mv $SA_VERSION $TRAVIS_BUILD_DIR/shared/
cp "$TRAVIS_BUILD_DIR/version.json" "$TRAVIS_BUILD_DIR/shared/version.json"
# Fetch the relevant S3 bucket & CodePipeline
export S3_BUCKET_NAME=`aws s3 ls | grep travissourcebucket | awk '{print $3}'`
export SA_NAME_WITHOUT_DASHES=`echo $SA_NAME | sed -e 's/-//g'`
export CODE_PIPELINE_NAME=`aws codepipeline list-pipelines | jq -r '.pipelines | .[] | .name' | grep "${SA_NAME_WITHOUT_DASHES}pipeline"`
export CC_REPO_CLONE_URL_HTTP=`aws codecommit get-repository --repository-name AppManifest-"$SA_NAME"-"$ROS_DISTRO"-gazebo"$GAZEBO_VERSION" | jq -r '.repositoryMetadata | .cloneUrlHttp'`
