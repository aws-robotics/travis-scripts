#!/bin/bash
set -e
touch version.json
echo testtest1 >> version.json

export CC_REPO_CLONE_URL_HTTP=`aws codecommit get-repository --repository-name AppManifest-"$SA_NAME"-"$ROS_DISTRO"-gazebo"$GAZEBO_VERSION" | jq -r '.repositoryMetadata | .cloneUrlHttp'`
# Clone the CC repository where version.json lives and commit the version.json file produced by current build
git clone "$CC_REPO_CLONE_URL_HTTP" cc-repo-for-version-file
cd cc-repo-for-version-file
cp "$TRAVIS_BUILD_DIR/shared/version.json" version.json
git add version.json
git commit -m "updating version.json file by commitId: $MASTER_COMMIT_ID"
git push
