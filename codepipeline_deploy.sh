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
export S3_BUCKET_NAME=`aws s3 ls | grep "travis-source" | awk '{print $3}'`
export SA_NAME_WITHOUT_DASHES=`echo $SA_NAME | sed -e 's/-//g'`
export CC_REPO_CLONE_URL_HTTP=`aws codecommit get-repository --repository-name AppManifest-"$SA_NAME"-"$ROS_DISTRO"-gazebo"$GAZEBO_VERSION" | jq -r '.repositoryMetadata | .cloneUrlHttp'`

# Clone the CC repository where version.json lives and commit the version.json file produced by current build
git clone "$CC_REPO_CLONE_URL_HTTP" cc-repo-for-version-file
cd cc-repo-for-version-file
cp "$TRAVIS_BUILD_DIR/shared/version.json" version.json
git add version.json
git commit -m "updating version.json file by commitId: $TRAVIS_COMMIT_MESSAGE"
git push
