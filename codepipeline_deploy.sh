#!/bin/bash
set -e

if [ ! -z "${TRAVIS_TAG}" ]; then
    # Do not run for builds triggered by tagging.
    echo "Skipping $0 $@"
    exit 0
fi

if [ -z "${PIPELINE_TIMEOUT}" ]; then
    # 30 minutes by default
    PIPELINE_TIMEOUT=1800
fi

# Start execution
PIPELINE_EXECUTION_ID=`aws codepipeline start-pipeline-execution --name "$CODE_PIPELINE_NAME"`
start_execution_exit_code=$?
if [ $start_execution_exit_code -ne 0 ]; then
    echo "Failed starting execution for pipeline ${CODE_PIPELINE_NAME}, exiting"
    exit $start_execution_exit_code
fi
PIPELINE_EXECUTION_ID=`echo ${PIPELINE_EXECUTION_ID} | jq -r .pipelineExecutionId`

starting_time=`date +%s`
retry_interval=5 # Poll every 5 seconds
elapsed_time=0

while [ $elapsed_time -lt $PIPELINE_TIMEOUT ]; do 
  status=`aws codepipeline get-pipeline-execution --pipeline-name "$CODE_PIPELINE_NAME" --pipeline-execution-id "$PIPELINE_EXECUTION_ID" | jq -r .pipelineExecution.status`
  echo "Pipeline status: $status"
  # status corresponds to https://docs.aws.amazon.com/codepipeline/latest/APIReference/API_PipelineExecution.html#CodePipeline-Type-PipelineExecution-status
  if [ "$status" = "Succeeded" ] || [ "$status" = "Superseded" ]; then
    echo "Pipeline execution finished."
    exit 0
  elif [ "$status" = "Failed" ]; then
    echo "Pipeline execution failed."
    exit 1
  else
    sleep $retry_interval
    let elapsed_time="`date +%s` - $starting_time"
  fi
done

echo "Reached timeout waiting for pipeline to finish."
exit 1
