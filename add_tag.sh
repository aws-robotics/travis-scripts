#!/bin/bash
set -e

# Set Travis fake user & email
git config --global user.email "${GH_USER_EMAIL}"
git config --global user.name "${GH_USER_NAME}"
# Set SSH url
git remote set-url origin git@github.com:${TRAVIS_REPO_SLUG}.git
# Add and push tag
git tag -a $SA_VERSION -m "Release $SA_VERSION"
git push origin $SA_VERSION
