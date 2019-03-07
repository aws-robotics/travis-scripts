import os
import sys

def update_version(file_path):
    if not os.path.exists(file_path):
        with open(file_path, 'wb') as f:
            f.write('{"application_version": "1.0.0"}\n')
        
if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise ValueError("Missing version file path parameter")
    update_version(sys.argv[1])
