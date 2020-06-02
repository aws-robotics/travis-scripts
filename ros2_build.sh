#!/bin/bash
set -xe

# install dependencies
sudo apt-get update && sudo apt-get install -y python3 python3-pip lcov cmake && rosdep update
sudo apt-get update && sudo apt-get install -y python3-rosinstall python3-colcon-common-extensions && sudo -H pip3 install -U setuptools coverage pytest
apt list --upgradable 2>/dev/null | awk {'print $1'} | sed 's/\/.*//g' | grep ${ROS_DISTRO} | xargs sudo apt-get install -y

REPO_NAME=$(basename -- ${TRAVIS_BUILD_DIR})
echo "repo: ${REPO_NAME} branch: ${TRAVIS_BRANCH}"

. "/opt/ros/${ROS_DISTRO}/setup.sh"

cd "/${ROS_DISTRO}_ws/"
if [ "${TRAVIS_BRANCH}" == "master" ] && [ -f "./src/${REPO_NAME}/.rosinstall.master" ]; then
    mkdir dep
    cd "/${ROS_DISTRO}_ws/dep"
    ln -s "../src/${REPO_NAME}/.rosinstall.master" .rosinstall
    rosws update
    cd "/${ROS_DISTRO}_ws/"
    rosdep install --from-paths src dep --ignore-src --rosdistro "${ROS_DISTRO}" -r -y
else
    rosdep install --from-paths src --ignore-src --rosdistro "${ROS_DISTRO}" -r -y
fi

# use colcon as build tool to build the package, and optionally build tests
colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-fprofile-arcs -ftest-coverage' -DCMAKE_C_FLAGS='-fprofile-arcs -ftest-coverage'

# run unit tests
if [ -z "${NO_TEST}" ]; then
    . ./install/setup.sh

    if [ "${TRAVIS_BRANCH}" == "master" ] && [ -d "./dep" ]; then
        touch dep/COLCON_IGNORE
    fi
    
    set +e
    colcon test --pytest-args --cov=. --cov-report=xml
    set -e
    colcon test-result --all --verbose

    # get unit test code coverage result
    case ${PACKAGE_LANG} in
        "cpp")
            lcov --capture --directory . --output-file coverage.info
            lcov --remove coverage.info '/usr/*' --output-file coverage.info
            lcov --list coverage.info
            cd "/${ROS_DISTRO}_ws/"
            sudo cp coverage.info /shared/
            ;;
        "python")
            # this doesn't actually support multiple packages
            sudo cp src/${REPO_NAME}/${PACKAGE_NAMES}/coverage.xml /shared/coverage.info
            ;;
    esac
fi
