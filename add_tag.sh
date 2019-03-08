#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Set up GitHub SSH Deploy Key
if [ ! -f ~/.ssh/github_deploy.pem ]; then
    cat $SCRIPT_DIR/ssh-config >> ~/.ssh/config && eval `ssh-agent -s`
    chmod 400 $TRAVIS_BUILD_DIR/github_deploy.pem && mv $TRAVIS_BUILD_DIR/github_deploy.pem ~/.ssh/ && ssh-add ~/.ssh/github_deploy.pem
fi

# Figure out what's the new version
python $SCRIPT_DIR/update_version.py "$TRAVIS_BUILD_DIR/version.json" "`git describe --abbrev=0 --tags 2>&1`"
export SA_VERSION=`cat $TRAVIS_BUILD_DIR/version.json | jq -r .application_version`
# Set Travis fake user & email
git config --global user.email "${GH_USER_EMAIL}"
git config --global user.name "${GH_USER_NAME}"
# Switch to SSH url
git remote set-url origin git@github.com:${TRAVIS_REPO_SLUG}.git
# Commit changes to package.xml files.
git status
env
# Add and push tag
git tag -a $SA_VERSION -m "Release $SA_VERSION"
git push origin $SA_VERSION
