{% set app_user = salt['pillar.get']('flask_app:app_user', 'deploy') %}

{{ app_user }}:
  user.present:
    - createhome: True
    - shell: /bin/bash

flask_requirements:
  pkg.installed:
    - pkgs:
      - git
      - python-pip

{% if salt['pillar.get']('flask_app:git_repo', None) %}
{% set vcs = 'git' %}
{% set repo = pillar['flask_app']['git_repo'] %}
{{ repo }}:
  git.latest:
    - name: {{repo}}
    - target: /home/{{ app_user }}/{{ salt['pillar.get']('flask_app:app_name', 'app') }}
    - rev: {{ salt['pillar.get']('flask_app:git_rev', 'master') }}
    - user: {{ app_user }}
    - require:
      - user: {{ app_user }}
      - pkg: flask_requirements
{% elif salt['pillar.get']('flask_app:hg_repo', None) %}
{% set vcs = 'hg' %}
{% set repo = pillar['flask_app']['hg_repo'] %}
{{ repo }}:
  hg.latest:
    - name: {{repo}}
    - target: /home/{{ app_user }}/{{ salt['pillar.get']('flask_app:app_name', 'app') }}
    - rev: {{ salt['pillar.get']('flask_app:hg_rev', 'default') }}
    - user: {{ app_user }}
    - require:
      - user: {{ app_user }}
{% endif %}

{% if salt['pillar.get']('flask_app:use_virtualenv', True) %}
app_requirements:
  virtualenv.managed:
    - requirements: {{ salt['pillar.get']('flask_app:requirements_path',
      '/home/{}/{}/requirements.txt'.format(app_user, salt['pillar.get']('flask_app:app_name', 'app'))) }}
    - cwd: /home/{{ app_user }}/app_env
    - python: {{ salt['pillar.get']('flask_app:python_bin', '/usr/bin/python') }}
    - name: /home/{{ app_user }}/app_env
    - system_site_packages: {{ salt['pillar.get']('flask_app:system_site_packages'), False }}
    - venv_bin: {{ salt['pillar.get']('flask_app:virtualenv_bin', '/usr/bin/virtualenv') }}
    - user: {{ app_user }}
{% else %}
app_requirements:
  pip.installed:
    - requirements: {{ salt['pillar.get']('flask_app:requirements_path',
      '/home/{}/{}/requirements.txt'.format(app_user, salt['pillar.get']('flask_app:app_name', 'app'))) }}
    - cwd: /home/{{ app_user }}/
    - user: {{ app_user  }}
    - no_site_packages: True
    - bin_env: /usr/local/bin/pip
    - require:
      - {{vcs}}: {{repo}}
      - pkg: flask_requirements
{% endif %}
