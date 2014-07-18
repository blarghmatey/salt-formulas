import os
import sys
# import os.path as op

formula_name = ('-').join(sys.argv[1:])

if len(formula_name) == 0:
    print("Please provide a formula name")
    sys.exit(1)

# root_path = os.getcwd()
path_names = ['{0}/{0}'.format(formula_name)]
os.makedirs(formula_name, mode=0o755, exist_ok=True)
for path in path_names:
    os.makedirs(path, mode=0o755, exist_ok=True)

file_names = ['{0}/pillar.example', '{0}/README.rst', '{0}/VERSION',
              '{0}/{0}/init.sls', '{0}/{0}/package_map.jinja']
for fname in file_names:
    os.mknod(fname.format(formula_name), mode=0o644)

with open('{0}/VERSION'.format(formula_name), 'w') as version:
    version.write('0.0.1\n')

with open('{0}/{0}/package_map.jinja'.format(formula_name), 'w') as pkg:
    pkg.write(
'''{{% set {0} = salt['grains.filter_by']({{
    'Debian': {{
        'pkgs': [
        ]
    }},
    'RedHat': {{
        'pkgs': [
        ]
    }},
    'Arch': {{
        'pkgs': [
        ]
    }}
}}, merge=salt['pillar.get']('{0}:lookup')) %}}
'''.format(formula_name))

with open('{0}/{0}/init.sls'.format(formula_name), 'w') as init:
    init.write(
'''{{% from "{0}/package_map.jinja" import {0} with context %}}
'''.format(formula_name))
