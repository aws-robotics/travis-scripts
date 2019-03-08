#!/bin/bash
set -e

# Move artifacts to shared/<version>/ and version.json to shared/
mkdir $SA_VERSION && mv shared/* $SA_VERSION && mv $SA_VERSION shared/
cp "version.json" "shared/version.json"
# Fetch the relevant S3 bucket & CodePipeline
export S3_BUCKET_NAME=`aws s3 ls | grep travissourcebucket | awk '{print $3}'`
export SA_NAME_WITHOUT_DASHES=`echo $SA_NAME | sed -e 's/-//g'`
export CODE_PIPELINE_NAME=`aws codepipeline list-pipelines | jq -r '.pipelines | .[] | .name' | grep "sam.*${SA_NAME_WITHOUT_DASHES}pipeline"`
