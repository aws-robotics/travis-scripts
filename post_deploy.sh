#!/bin/bash
set -e

if [ "${TRAVIS_EVENT_TYPE}" == "cron"]; then
    # Do not run for builds triggered by cron jobs.
    echo "Skipping cron-job-triggered builds"
    exit 0
fi

if [ ! -z "${TRAVIS_TAG}" ]; then
    # Do not run for builds triggered by tagging.
    echo "Skipping $0 $@"
    exit 0
fi
