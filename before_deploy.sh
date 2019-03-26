#!/bin/bash
set +e

export MASTER_COMMIT_ID=`aws codecommit get-file --repository-name "${CC_REPO_NAME}" --file-path version.json | jq -r '.commitId'`
if [ "$?" -ne "0" ]; then
    echo version.json file does not yet exist in CodeCommit repository named "$CC_REPO_NAME"
    exit 0
fi
