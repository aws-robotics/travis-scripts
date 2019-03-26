#!/bin/bash
set -e

git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true
