#!/bin/bash
export SA_VERSION=1
touch version.json
echo testtest1 >> version.json

# Move artifacts to shared/<version>/ and version.json to shared/

MASTER_COMMIT_ID=`aws codecommit get-file --repository-name "${CC_REPO_NAME}" --file-path version.json`
if [ $? -ne 0 ]; then
    echo test
else
    export MASTER_COMMIT_ID=`echo $MASTER_COMMIT_ID | jq -r '.commitId'`
fi
