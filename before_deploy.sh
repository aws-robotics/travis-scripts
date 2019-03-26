#!/bin/bash
set -e

export MASTER_COMMIT_ID=`aws codecommit get-file --repository-name "${CC_REPO_NAME}" --file-path version.json | jq -r '.commitId'`
