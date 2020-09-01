#!/bin/bash
set -xe

# install dependencies
sudo apt-get update && sudo apt-get install -y lcov python3-pip python-rosinstall libgtest-dev cmake && rosdep update
sudo apt-get update && sudo apt-get install -y python3-colcon-common-extensions && sudo -H pip3 install -U setuptools<50.0.0
# nosetests needs coverage for Python 2
sudo apt-get install python-pip -y && sudo -H pip install -U coverage
# enable Python coverage "https://github.com/ros/catkin/blob/kinetic-devel/cmake/test/nosetests.cmake#L59"
export CATKIN_TEST_COVERAGE=1

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

# build and run unit tests
if [ -z "${NO_TEST}" ]; then
    if [ ! -z "${PACKAGE_NAMES}" ]; then
        colcon build --packages-select ${PACKAGE_NAMES} --cmake-target tests
    fi

    . ./install/setup.sh

    if [ "${TRAVIS_BRANCH}" == "master" ] && [ -d "./dep" ]; then
        touch dep/COLCON_IGNORE
    fi
    
    set +e
    colcon test
    set -e
    colcon test-result --all --verbose
    
    # get unit test code coverage result
    case ${PACKAGE_LANG} in
        "cpp")
            lcov --capture --directory . --output-file coverage.info
            if [ "${ROS_DISTRO}" == "kinetic" ]; then
                # kinetic is using xenial, which is using lcov 1.12, which has a bug.
                # see https://github.com/linux-test-project/lcov/commit/632c25a0d1f5e4d2f4fd5b28ce7c8b86d388c91f
                sudo lcov --remove coverage.info '/usr/*' --output-file coverage.info
            else
                lcov --remove coverage.info '/usr/*' --output-file coverage.info
            fi
            lcov --list coverage.info
            cd "/${ROS_DISTRO}_ws/"
            sudo cp coverage.info /shared/
            ;;
        "python")
            # this doesn't actually support multiple packages
            cd "/${ROS_DISTRO}_ws/build/${PACKAGE_NAMES}"
            coverage xml
            sudo cp coverage.xml /shared/coverage.info
            ;;
    esac
fi
