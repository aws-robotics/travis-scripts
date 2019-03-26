#!/bin/bash
export SA_VERSION=1
# Move artifacts to shared/<version>/ and version.json to shared/
mkdir "$SA_VERSION" && mv "$TRAVIS_BUILD_DIR"/shared/* "$SA_VERSION" && mv "$SA_VERSION" "$TRAVIS_BUILD_DIR"/shared/
cp "$TRAVIS_BUILD_DIR/version.json" "$TRAVIS_BUILD_DIR/shared/version.json"

MASTER_COMMIT_ID=`aws codecommit get-file --repository-name "${CC_REPO_NAME}" --file-path version.json`
if [ $? -ne 0 ]; then
    echo test
else
    export MASTER_COMMIT_ID=`echo $MASTER_COMMIT_ID | jq -r '.commitId'`
fi
