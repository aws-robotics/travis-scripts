#!/bin/bash
MASTER_COMMIT_ID=`aws codecommit get-file --repository-name test1 --file-path test1`
if [ $? -ne 0 ]; then
    echo test
else
    export MASTER_COMMIT_ID=`echo $MASTER_COMMIT_ID | jq -r '.commitId'`
fi
