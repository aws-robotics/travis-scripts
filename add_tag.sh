#!/bin/bash
set -e

if [ ! -z "${TRAVIS_TAG}" ]; then
    # Do not run for builds triggered by tagging.
    echo "Skipping $0 $@"
    exit 0
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Set up GitHub SSH Deploy Key
if [ ! -f ~/.ssh/github_deploy.pem ]; then
    cat $SCRIPT_DIR/ssh-config >> ~/.ssh/config && eval `ssh-agent -s`
    chmod 400 $TRAVIS_BUILD_DIR/github_deploy.pem && mv $TRAVIS_BUILD_DIR/github_deploy.pem ~/.ssh/ && ssh-add ~/.ssh/github_deploy.pem
fi

if [ ! -z "${SHOULD_UPDATE_VERSION}" ]; then
    # Use git tag for versioning, updating package.xml in the process
    # Figure out what's the new version
    python $SCRIPT_DIR/update_version.py "$TRAVIS_BUILD_DIR/version.json" "`git describe --abbrev=0 --tags 2>&1`"
    export SA_VERSION=`cat $TRAVIS_BUILD_DIR/version.json | jq -r .application_version`
    # Set Travis fake user & email
    git config --global user.email "${GH_USER_EMAIL}"
    git config --global user.name "${GH_USER_NAME}"
    # Switch to SSH url
    git remote set-url origin git@github.com:${TRAVIS_REPO_SLUG}.git
    # Add and push tag
    git tag -a $SA_VERSION -m "Release $SA_VERSION"
    git push origin $SA_VERSION
else 
    # Use Travis build number for versioning; Git tags & package manifest will not be updated.
    stored_pwd=`pwd`
    cd $SCRIPT_DIR && CURRENT_SA_VERSION=`python -c "import update_version; print update_version.get_current_package_xml_version()"`
    cd $stored_pwd
    export SA_VERSION=${CURRENT_SA_VERSION}.${TRAVIS_BUILD_NUMBER}
    echo {\"application_version\": \"${SA_VERSION}\"} > "$TRAVIS_BUILD_DIR/version.json"
fi
