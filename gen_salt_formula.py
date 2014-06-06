import os
import sys
import os.path as op

formula_name = ('_').join(sys.argv[1:])

if len(formula_name) == 0:
    print("Please provide a formula name")
    return

root_path = op.join(os.getcwd(), formula_name)
path_names = ['{0}/{0}'.format(formula_name)]
os.makedirs(root_path, mode=0o755, exist_ok=True)
for path in path_names:
    os.makedirs(op.join(root_path, path), mode=0o755, exist_ok=True)

file_names = ['{0}/pillar.example', '{0}/README.rst', '{0}/VERSION', '{0}/{0}/init.sls', '{0}/{0}/package_map.jinja']
for fname in file_names:
    os.mknod(op.join(root_path, fname.format(formula_name)), mode=0o644)

with open('{}/VERSION'.format(formula_name), 'w') as version:
    version.write('0.0.1')
