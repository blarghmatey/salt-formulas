{% from "postgresql/package_map.jinja" import postgres with context %}

postgresql:
  pkg:
    - installed
    - name: {{postgres.pkg}}
  service:
    - running
    - enable: True
    - name: {{postgres.service}}
    - require:
      - pkg: {{postgres.pkg}}

postgresql_user:
  postgres_user.present:
    - name: {{salt['pillar.get']('postgres:user:name', 'root')}}
    - createdb: {{salt['pillar.get']('postgres:user:createdb', False)}}
    - password: {{salt['pillar.get']('postgres:user:password', 'P@ssw0rd')}}
    - superuser: {{salt['pillar.get']('postgres:user:superuser', False)}}
    - login: {{salt['pillar.get']('postgres:user:login', True)}}
    - createroles: {{salt['pillar.get']('postgres:user:createroles', False)}}
    - encrypted: {{salt['pillar.get']('postgres:user:encrypt_password', True)}}
    - require:
      - service: {{postgres.service}}

{% if salt['pillar.get']('postgres:database', None) %}
postgresql_database:
  postgres_database.present:
    - name: {{salt['pillar.get']('postgres:database:name', 'sample_db')}}
    - encoding: {{salt['pillar.get']('postgres:database:encoding', 'UTF8')}}
    - owner: {{salt['pillar.get']('postgres:database:owner', 'root')}}
    - template: template0
    - require:
      - postgres_user: {{salt['pillar.get']('postgres:user:name', 'root')}}
{% endif %}
