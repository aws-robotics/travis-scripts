#!/bin/bash
set -e

if [ ! -z "${TRAVIS_TAG}" ]; then
    # Do not run for builds triggered by tagging.
    echo "Skipping $0 $@"
    exit 0
fi

# Restore default setting to be able to safely source this script in Travis: https://github.com/travis-ci/travis-ci/issues/891
set +e
