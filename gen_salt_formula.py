import os
import sys
import argparse
# import os.path as op

parser = argparse.ArgumentParser(
    description="Generate a salt formula skeleton")
parser.add_argument('--state', dest='is_state', type=bool, default=False)
parser.add_argument('formula_name', nargs='+', type=str)

args = parser.parse_args()
formula_name = ('-').join(args.formula_name)

if len(formula_name) == 0:
    print("Please provide a formula name")
    sys.exit(1)

# root_path = os.getcwd()
if args.is_state:
    path_names = ['{0}/files'.format(formula_name)]
else:
    path_names = ['{0}/{0}'.format(formula_name)]
os.makedirs(formula_name, mode=0o755, exist_ok=True)
for path in path_names:
    os.makedirs(path, mode=0o755, exist_ok=True)

if args.is_state:
    file_names = ['{0}/init.sls', '{0}/package_map.jinja']
else:
    file_names = ['{0}/pillar.example', '{0}/README.rst', '{0}/VERSION',
                  '{0}/{0}/init.sls', '{0}/{0}/package_map.jinja']

for fname in file_names:
    os.mknod(fname.format(formula_name), mode=0o644)

if not args.is_state:
    with open('{0}/VERSION'.format(formula_name), 'w') as version:
        version.write('0.0.1\n')

with open(file_names[-1].format(formula_name), 'w') as pkg:
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

with open(file_names[-2].format(formula_name), 'w') as init:
    init.write(
'''{{% from "{0}/package_map.jinja" import {0} with context %}}
'''.format(formula_name))
