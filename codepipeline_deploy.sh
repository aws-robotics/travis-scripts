#!/bin/bash
set -e

if [ ! -z "${TRAVIS_TAG}" ]; then
    # Do not run for builds triggered by tagging.
    echo "Skipping $0 $@"
    exit 0
fi

# Clone the CC repository where version.json lives and commit the version.json file produced by current build
git clone "$CC_REPO_CLONE_URL_HTTP" cc-repo-for-version-file
cd cc-repo-for-version-file
cp "$TRAVIS_BUILD_DIR/shared/version.json" version.json
git add version.json
git commit -m "updating version.json file by commitId: $TRAVIS_COMMIT_MESSAGE"
git push
