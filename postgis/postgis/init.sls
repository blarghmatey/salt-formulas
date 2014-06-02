{% if grains['os_family'] == 'Debian' %}
python-software-properties:
  pkg.installed

postgis_repo:
  pkgrepo.managed:
    - ppa: ubuntugis/ppa
    - require:
      - pkg: python-software-properties
  pkg.latest:
    - name: postgis
    - refresh: True
{% elif grains['os_family'] == 'Arch' %}
postgis:
  pkg.installed
{% endif %}

{% if 'postgis' in pillar['postgres'].get('extensions', None) %}
{% set dbname = pillar['postgres']['database'].get('name', 'sample_db') %}
{% for extension in pillar['postgres']['extensions'] %}
{{extension}}:
  cmd.run:
    - name: psql -c 'create extension if not exists {{extension}}' {{dbname}}
    - user: postgres
    - require:
      - pkg: postgis
      - postgres_database: {{dbname}}
{% endfor %}
{% endif %}
