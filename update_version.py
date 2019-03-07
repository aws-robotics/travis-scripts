import os
import sys

VERSION_COMPONENTS_TO_IDX = {'major': 0, 'minor': 1, 'patch': 2}

def version_increment(version, increment_type='patch'):
    components = version.split('.')
    components[VERSION_COMPONENTS_TO_IDX[increment_type]] = str(int(components[VERSION_COMPONENTS_TO_IDX[increment_type]]) + 1)
    return '.'.join(components)

def update_version(file_path, current_version):
    new_version = version_increment(current_version)
    with open(file_path, 'wb') as f:
        f.write('{"application_version": "%s"}\n' % (new_version, ))
        
if __name__ == '__main__':
    if len(sys.argv) < 3:
        raise ValueError("update_version.py <version file path> <current version>")
    update_version(sys.argv[1], sys.argv[2])
