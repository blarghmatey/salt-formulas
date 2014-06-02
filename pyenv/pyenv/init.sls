{% set pyenv_user = pillar.get('pyenv:user', 'root') %}
{% set python_version = pillar.get('pyenv:version', '3.3.4') %}
{% from "pyenv/package_map.jinja" import pyenv with context %}
{% if pyenv_user == 'root' %}
  {% set home_prefix = '' %}
{% else %}
  {% set home_prefix = '/home' %}
{% endif %}

pyenv_required_pkgs:
  pkg.installed:
    - pkgs: {{pyenv.pkgs}}

pyenv_user:
  user.present:
    - name: {{pyenv_user}}
    - createhome: True
    - shell: /bin/bash

pyenv:
  git.latest:
    - rev: master
    - target: {{home_prefix}}/{{pyenv_user}}/.pyenv
    - name: https://github.com/yyuu/pyenv.git
    - user: {{pyenv_user}}
    - require:
      - pkg: pyenv_required_pkgs
      - user: pyenv_user

bashrc:
  file.append:
    - name: {{home_prefix}}/{{pyenv_user}}/.bashrc
    - sources:
      - salt://pyenv/bashrc_additions
    - require:
      - git: pyenv

python_install:
  cmd.script:
    - source: salt://pyenv/version_install.sh
    - args: {{python_version}}
    - shell: /bin/bash
    - stateful: True
    - output_loglevel: DEBUG
    - reload_modules: True
    - user: {{pyenv_user}}
    - cwd: {{home_prefix}}/{{pyenv_user}}/
    - require:
      - file: bashrc
      - pkg: pyenv_required_pkgs
