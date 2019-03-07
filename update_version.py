import os
import sys
import subprocess
import xml.etree.ElementTree as ET
from distutils.version import StrictVersion

VERSION_COMPONENTS_TO_IDX = {'major': 0, 'minor': 1, 'patch': 2}
FIRST_VERSION = '1.0.0'
FIRST_VERSION_WITH_EXISTING_OBSOLETE_TAGS = '1.1.0'

def version_increment(version, increment_type='patch'):
    components = version.split('.')
    if len(components) != 3:
        # Version is not bootstrapped properly. Either there was no release yet (no tags) or the format is obsolete.
        if 'No names found' in version:
            return FIRST_VERSION
        else:
            return FIRST_VERSION_WITH_EXISTING_OBSOLETE_TAGS
    else:
        components[VERSION_COMPONENTS_TO_IDX[increment_type]] = str(int(components[VERSION_COMPONENTS_TO_IDX[increment_type]]) + 1)
        return '.'.join(components)

def update_version(file_path, current_version, package_name):
    new_version = version_increment(current_version)
    # Create ephemeral version.json in order to tell the internal build system which version should be built.
    with open(file_path, 'wb') as f:
        f.write('{"application_version": "%s"}\n' % (new_version, ))
    # Update the version in package.xml if not up to date & commit
    package_xml_path = get_path_to_package_xml()
    if not package_xml_path:
        # Skip updating package.xml
        return
    xml_tree = ET.parse(package_xml_path)
    xml_root = xml_tree.getroot()
    version_element = root.findall('version')[0]
    if StrictVersion(version_element.text) == StrictVersion(new_version):
        print 'package.xml already up to date with version %s, not updating.' % (new_version, )
    elif StrictVersion(version_element.text) > StrictVersion(new_version):
        raise ValueError('The version in package.xml (%s) is newer than the version intended to be released (%s)' % (version_element.text, new_version, ))
    else:
        version_element.text = new_version
        tree.write(package_xml_path)
    # TODO: git commit, push / open PR.
        
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
