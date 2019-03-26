#!/bin/bash
set -e

MASTER_COMMIT_ID=`aws codecommit get-file --repository-name "${CC_REPO_NAME}" --file-path version.json` || exit 0
export MASTER_COMMIT_ID=`echo $MASTER_COMMIT_ID | jq -r '.commitId'`
