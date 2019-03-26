#!/bin/bash
set -e
touch version.json
echo testtest1 >> version.json

echo $MASTER_COMMIT_ID
# Upload version.json to CodeCommit
if [ ! -z "${MASTER_COMMIT_ID}" ]; then
    echo test
    # version.json file being uploaded the first time
    aws codecommit put-file --repository-name "${CC_REPO_NAME}" --branch-name master --file-content file://./version.json --file-path version.json --file-mode normal --commit-message "$TRAVIS_COMMIT_MESSAGE" --name "$GH_USER_NAME" --email "$GH_USER_EMAIL"
else
    echo here
    aws codecommit put-file --repository-name "${CC_REPO_NAME}" --branch-name master --file-content file://./version.json --file-path version.json --file-mode normal --commit-message "$TRAVIS_COMMIT_MESSAGE" --name "$GH_USER_NAME" --email "$GH_USER_EMAIL" --parent-commit-id "$MASTER_COMMIT_ID"

fi


