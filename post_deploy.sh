#!/bin/bash
set -e

aws codepipeline start-pipeline-execution --name $CODE_PIPELINE_NAME
# TODO: Potentially wait until the pipeline build completes and succeed the Travis build accordingly.
