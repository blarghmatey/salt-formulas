{% from "uwsgi/package_map.jinja" import uwsgi with context %}
{% set python = salt['pillar.get']('uwsgi:python_bin', '/usr/bin/python') %}

uwsgi_packages:
  pkg.installed:
    - pkgs: {{ uwsgi.pkgs }}

uwsgi_source:
  git.latest:
    - name: https://github.com/unbit/uwsgi.git
    - target: /usr/local/uwsgi
    - rev: {{ salt['pillar.get']('uwsgi:version', '2.0.1') }}
    - require:
      - pkg: uwsgi_packages

uwsgi_compile:
  cmd.run:
    - name: {{python}} uwsgiconfig.py --build {{ salt['pillar.get']('uwsgi:build_params', '') }}
    - cwd: /usr/local/uwsgi/
    - unless: /usr/local/bin/uwsgi --version | grep {{ salt['pillar.get']('uwsgi:version', '2.0.1') }}
    - require:
      - git: uwsgi_source

/usr/local/bin/uwsgi:
  file.symlink:
    - target: /usr/local/uwsgi/uwsgi
    - require:
      - cmd: uwsgi_compile

/etc/uwsgi/vassals:
  file.directory:
    - makedirs: True

/var/log/uwsgi:
  file.directory:
    - makedirs: True

/etc/uwsgi/emperor.ini:
  file.managed:
    - source: salt://uwsgi/emperor.ini

{% if grains['os'] == 'Ubuntu' %}
/etc/init/uwsgi.conf:
  file.managed:
    - source: salt://uwsgi/uwsgi.upstart
{% else %}
/usr/lib/systemd/system/uwsgi.service:
  file.managed:
    - source: salt://uwsgi/uwsgi.systemd
{% endif %}

uwsgi_service:
  service.running:
    - enable: True
    - name: uwsgi
    - require:
      - file: /usr/local/bin/uwsgi
      - file: /etc/uwsgi/emperor.ini
      {% if grains['os'] == 'Ubuntu' %}
      - file: /etc/init/uwsgi.conf
      {% else %}
      - file: /usr/lib/systemd/system/uwsgi.service
      {% endif %}
    - watch:
      - file: /etc/uwsgi/emperor.ini
