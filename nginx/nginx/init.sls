{% from "nginx/package_map.jinja" import nginx with context %}
{% set nginx_version = salt['pillar.get']('nginx:version', '1.4.5') %}
{% set pcre_version = salt['pillar.get']('nginx:pcre_version', '8.32') %}

{% if salt['pillar.get']('nginx:package', False) %}
nginx:
  pkg:
    - installed
  service:
    - running
    - enabled: True
    - require:
      - pkg: nginx
{% else %}
nginx_requirements:
  pkg.installed:
    - pkgs: {{ nginx.pkgs }}

nginx_user:
  user.present:
    - name: http
    - createhome: False
    - system: True

nginx_source:
  hg.latest:
    - target: /tmp/nginx
    - name: http://hg.nginx.org/nginx
    - rev: release-{{ nginx_version }}
    - require:
      - pkg: nginx_requirements

/etc/nginx/sites-enabled:
  file.directory:
    - makedirs: True

/etc/nginx/sites-available:
  file.directory:
    - makedirs: True

/etc/nginx/conf.d/:
  file.directory:
    - makedirs: True

/var/log/nginx:
  file.directory:
    - makedirs: True
    - uid: http
    - gid: http

nginx_configure:
  cmd.wait:
    - name: auto/configure --conf-path=/etc/nginx/nginx.conf
          --sbin-path=/usr/sbin/nginx
          --pid-path=/var/run/nginx.pid
          --lock-path=/var/lock/nginx.lock
          --with-http_geoip_module
          --with-http_ssl_module
          --with-ipv6
          --prefix=/etc/nginx
          --with-debug
          --with-http_gzip_static_module
          --with-http_realip_module
          --with-http_xslt_module
          --with-http_stub_status_module
          --with-pcre
    - cwd: /tmp/nginx/
    - unless: nginx -v | grep {{ nginx_version }}
    - watch:
      - hg: nginx_source
    - require:
      - hg: nginx_source

nginx_compile:
  cmd.wait:
    - name: make install
    - cwd: /tmp/nginx
    - unless: nginx -v | grep {{ nginx_version }}
    - watch:
      - cmd: nginx_configure
    - require:
      - cmd: nginx_configure

{% if grains['os'] == 'Ubuntu' %}
/etc/init/nginx.conf:
  file.managed:
    - source: salt://nginx/nginx.upstart
{% else %}
/usr/lib/systemd/system/nginx.service:
  file.managed:
    - source: salt://nginx/nginx.systemd
{% endif %}

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://nginx/nginx.conf
    - template: jinja
    - context:
        worker_count: {{ salt['pillar.get']('nginx:worker_count', 2) }}
    - require:
      - cmd: nginx_compile

nginx_service:
  service.running:
    - enable: True
    - name: nginx
    - require:
      - cmd: nginx_compile
      {% if grains['os'] == 'Ubuntu' %}
      - file: /etc/init/nginx.conf
      {% else %}
      - file: /usr/lib/systemd/system/nginx.service
      {% endif %}
    - watch:
      - file: /etc/nginx/nginx.conf
{% endif %}
