#!/bin/bash
set -e

if [ ! -z "${TRAVIS_TAG}" ]; then
    # Do not run for builds triggered by tagging.
    echo "Skipping $0"
    exit 0
fi

aws codepipeline start-pipeline-execution --name $CODE_PIPELINE_NAME
# TODO: Potentially wait until the pipeline build completes and succeed the Travis build accordingly.
