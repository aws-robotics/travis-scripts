import os

if not os.path.exists('version.json'):
    with open('version.json', 'wb') as f:
        f.write('{"application_version": "1.0.0"}')
