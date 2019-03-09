"""Version updater for Sample Applications

This script helps cut a new release for ROS applications which are not intended to be released via bloom, and is meant to be invoked automatically as part of a Travis CI job.
It takes in a path indicating where the version.json file should be created, and the current version of the application (typically provided by `git describe`).
It also relies on the environment variables TRAVIS_BUILD_DIR and SA_PACKAGE_NAME being preset (the latter implies which package manifest should be updated).

The tool performs the following actions:
1. Determines what is the new version (bumps the patch component by default).
2. Creates a version.json file with the new version string.
3. Updates package.xml if necessary. 
"""

import os
import sys
import subprocess
import xml.etree.ElementTree as ET
from distutils.version import StrictVersion

VERSION_COMPONENTS_TO_IDX = {'major': 0, 'minor': 1, 'patch': 2}
FIRST_VERSION = '1.0.0'
# If the repository already contains tags in an unsupported format (e.g. b1.0.58.0.1.0.51.0), bump to the following version.
FIRST_VERSION_WITH_EXISTING_OBSOLETE_TAGS = '1.1.0'

def get_incremented_version(version, increment_type='patch'):
    components = version.split('.')
    if len(components) != 3:
        # Either there was no release yet (no tags) or the tag format is invalid.
        if 'No names found' in version:
            return FIRST_VERSION
        else:
            return FIRST_VERSION_WITH_EXISTING_OBSOLETE_TAGS
    else:
        # Bump version according to increment_type
        components[VERSION_COMPONENTS_TO_IDX[increment_type]] = str(int(components[VERSION_COMPONENTS_TO_IDX[increment_type]]) + 1)
        return '.'.join(components)

def update_version(file_path, current_version):
    new_version = get_incremented_version(current_version)
    # Create ephemeral version.json in order to tell the internal build system which version should be built.
    with open(file_path, 'wb') as f:
        f.write('{"application_version": "%s"}\n' % (new_version, ))
        
    # Update version in package.xml if needed.
    package_xml_path = get_path_to_package_xml()
    if not package_xml_path:
        print 'Skipping package.xml update as it could not be located (Does the environment contain TRAVIS_BUILD_DIR and SA_PACKAGE_NAME?)'
        return
    xml_tree = ET.parse(package_xml_path)
    xml_root = xml_tree.getroot()
    version_element = xml_root.findall('version')[0]
    if StrictVersion(version_element.text) == StrictVersion(new_version):
        print 'package.xml already up to date with version %s, not updating.' % (new_version, )
    elif StrictVersion(version_element.text) > StrictVersion(new_version):
        raise ValueError('The version in package.xml (%s) is newer than the version intended to be released (%s)' % (version_element.text, new_version, ))
    else:
        version_element.text = new_version
        xml_tree.write(package_xml_path)
    # TODO: git commit, push / open PR.
    
def get_current_package_xml_version():
    package_xml_path = get_path_to_package_xml()
    if not package_xml_path:
        return None
    xml_tree = ET.parse(package_xml_path)
    xml_root = xml_tree.getroot()
    version_element = xml_root.findall('version')[0]
    return version_element.text
        
def get_path_to_package_xml():
    """
    @note assumes the environment contains TRAVIS_BUILD_DIR and SA_PACKAGE_NAME.
    """
    if 'TRAVIS_BUILD_DIR' in os.environ and 'SA_PACKAGE_NAME' in os.environ:
        search_cmd = 'find %s -name "package.xml" -path "*/%s/*"' % (os.environ['TRAVIS_BUILD_DIR'], os.environ['SA_PACKAGE_NAME'], )
        return subprocess.check_output(search_cmd, shell=True).strip()
    else:
        return None
        
if __name__ == '__main__':
    if len(sys.argv) < 3:
        raise ValueError("Missing parameters. Usage: update_version.py <version file path> <current version>")
    version_file_path, current_version = sys.argv[1:]
    update_version(version_file_path, current_version)
