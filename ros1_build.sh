#!/bin/bash
set -xe

# install dependencies
apt update && apt install -y lcov python3-pip python-rosinstall libgtest-dev cmake && rosdep update
apt update && apt install -y python3-colcon-common-extensions && pip3 install -U setuptools
# nosetests needs coverage for Python 2
apt-get install python-pip -y && pip install -U coverage
# enable Python coverage "https://github.com/ros/catkin/blob/kinetic-devel/cmake/test/nosetests.cmake#L59"
export CATKIN_TEST_COVERAGE=1

REPO_NAME=$(basename -- ${TRAVIS_BUILD_DIR})
echo "repo: ${REPO_NAME} branch: ${TRAVIS_BRANCH}"

cd "/${ROS_DISTRO}_ws/"
# use colcon as build tool to build the package, and optionally build tests
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

. "/opt/ros/${ROS_DISTRO}/setup.sh"

colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_FLAGS='-fprofile-arcs -ftest-coverage' -DCMAKE_C_FLAGS='-fprofile-arcs -ftest-coverage'

if [ -z "${NO_TEST}" ]; then
    if [ ! -z "${PACKAGE_NAMES}" ]; then
        colcon build --packages-select ${PACKAGE_NAMES} --cmake-target tests
    fi

    # run unit tests
    . ./install/setup.sh

    if [ "${TRAVIS_BRANCH}" == "master" ] && [ -d "./dep" ]; then
        touch dep/COLCON_IGNORE
    fi

    colcon test
    colcon test-result --all --verbose

    # get unit test code coverage result
    case ${PACKAGE_LANG} in
        "cpp")
            lcov --capture --directory . --output-file coverage.info
            lcov --remove coverage.info '/usr/*' --output-file coverage.info
            lcov --list coverage.info
            cd "/${ROS_DISTRO}_ws/"
            mv coverage.info /shared
            ;;
        "python")
            # this doesn't actually support multiple packages
            cd "/${ROS_DISTRO}_ws/build/${PACKAGE_NAMES}"
            coverage xml
            cp coverage.xml /shared/coverage.info
            ;;
    esac
fi
