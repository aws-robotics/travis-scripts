#!/bin/bash
set -e
touch version.json
echo testtest1 >> version.json

touch version.json
echo testtest1 >> version.json

# Move artifacts to shared/<version>/ and version.json to shared/

MASTER_COMMIT_ID=`aws codecommit get-file --repository-name "${CC_REPO_NAME}" --file-path version.json`
echo $MASTER_COMMIT_ID
if [ $? -ne 0 ]; then
    echo test
    exit 0
fi
export MASTER_COMMIT_ID=`echo $MASTER_COMMIT_ID | jq -r '.commitId'`
echo $MASTER_COMMIT_ID

# Upload version.json to CodeCommit
if [ -z "${MASTER_COMMIT_ID}" ]; then
    echo test
    # version.json file being uploaded the first time
    aws codecommit put-file --repository-name "${CC_REPO_NAME}" --branch-name master --file-content file://./version.json --file-path version.json --file-mode normal --commit-message "$TRAVIS_COMMIT_MESSAGE" --name "$GH_USER_NAME" --email "$GH_USER_EMAIL"
else
    echo here
    aws codecommit put-file --repository-name "${CC_REPO_NAME}" --branch-name master --file-content file://./version.json --file-path version.json --file-mode normal --commit-message "$TRAVIS_COMMIT_MESSAGE" --name "$GH_USER_NAME" --email "$GH_USER_EMAIL" --parent-commit-id "$MASTER_COMMIT_ID"

fi


