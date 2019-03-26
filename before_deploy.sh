#!/bin/bash

if MASTER_COMMIT_ID=`aws codecommit get-file --repository-name "${CC_REPO_NAME}" --file-path version.json` || exit 0; then
    export MASTER_COMMIT_ID=`echo $MASTER_COMMIT_ID | jq -r '.commitId'`
fi
