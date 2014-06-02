#!/bin/bash

source ~/.bashrc

python_version=$1

if [ `whoami` == 'root' ]
then
    if [ ! -e '/usr/local/bin/python' ]
    then
        ~/.pyenv/plugins/python-build/bin/python-build $python_version /usr/local/
        pip install virtualenv
    fi
else
    if [ ! -e '~/.pyenv/versions/$python_version/bin/python' ]
    then
        ~/.pyenv/bin/pyenv install $python_version
        ~/.pyenv/bin/pyenv global $python_version
    fi
fi

echo "changed=true"
