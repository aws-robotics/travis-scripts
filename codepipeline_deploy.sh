#!/bin/bash
set -e

echo "$TRAVIS_BUILD_DIR/shared/version.json"
echo "${CC_REPO_NAME}"
# Upload version.json to CodeCommit
if [ -z "${MASTER_COMMIT_ID}" ]; then
    # version.json file being uploaded the first time
    aws codecommit put-file --repository-name "${CC_REPO_NAME}" --branch-name master --file-content file://"$TRAVIS_BUILD_DIR/version.json" --file-path version.json --file-mode normal
else
    aws codecommit put-file --repository-name "${CC_REPO_NAME}" --branch-name master --file-content file://"$TRAVIS_BUILD_DIR/version.json" --file-path version.json --file-mode normal
fi


