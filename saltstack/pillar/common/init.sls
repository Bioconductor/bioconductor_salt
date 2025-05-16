{% from '../custom/init.sls' import branch, version, environment,
   r_download, r_version, r_previous_version, cran_mirror, cycle, name,
   create_users, machine_type %}

{% if machine_type == 'standalone' %}
{# Assuming salt is run is /Users/a_user or /home/a_user, take the last
   directory as the user name #}
{% set build_user = grains['cwd'].split("/")[-1] %}
{% else %}
{% if create_users %}
{% from '../custom/init.sls' import biocbuild_password, biocbuild_key,
   biocbuild_authorized_key, biocpush_password, biocpush_key,
   biocpush_authorized_key %}
{% endif %}
{% set build_user = 'biocbuild' %}
{% endif %} 

{%- if branch == 'release' %}
{% set current_branch = 'RELEASE_' ~ version.replace(".", "_") %}
{% else %}
{% set current_branch = 'devel' %}
{%- endif %}

{%- if grains['os'] == 'Ubuntu' %}
{% set user_home = '/home' %}
{% set shell = '/usr/bin/bash' %}
{% set slash = '/' %}
{% elif grains['os'] == 'MacOS' %}
{% set user_home = '/Users' %}
{% set shell = '/usr/bin/sh' %}
{% set slash = '/' %}
{%- endif %}

{# See machine.users below to add more users #}

build:
  branch: {{ branch }}
  cycle: {{ cycle }}
  version: {{ version }}
  types:
    - bioc                  {# always required #}

machine:
  name: {{ name }}
  env: {{ environment }}
  slash: {{ slash }}
  ip: 127.0.1.1
  cores: {{ grains['num_cpus'] }}  {# to find out available cores, run cat /proc/cpuinfo | grep processor | wc -l #}
  type: {% if machine_type != "" %}{{ machine_type }}{% else %}secondary{% endif %}
  create_users: {% if create_users is defined %}{{ create_users }}{% else %}True{% endif %}
  {%- if grains['os'] == 'Ubuntu' %}
  r_path: {{ user_home }}/{{ build_user }}/bbs-{{ version }}-bioc/R/bin/
  groups: 
    {%- if machine_type in ['primary', 'secondary'] %}
    - {{ build_user }}
    {% endif %}
    {%- if machine_type == 'primary' %}
    - biocpush
    - bioconductor
    {%- endif %}
  {% endif %}
  user:
    name: {{ build_user }}
    home: {{ user_home }}
    shell: {{ shell }}
  users:
    {% if create_users %}
    - name: {{ build_user }}
      key: {{ biocbuild_key }}
      password: {{ biocbuild_password }}
      groups:
        {%- if grains['os'] == 'Ubuntu' %}
        - biocbuild
        {% elif grains['os'] == 'MacOS' %}
        - staff
        {% endif %}
      authorized_keys:
        - {{ biocbuild_authorized_key }}
    {% if machine_type == 'primary' %}
    - name: biocpush
      key: {{ biocpush_key }}
      password: {{ biocpush_password }}
      groups:
        - biocpush
      authorized_keys:
        - {{ biocpush_authorized_key }}
    {% endif %}
    {% endif %}

r:
  download: {{ r_download }}
  version: {{ r_version }}
  previous_version: {{ r_previous_version }}
  cran_mirror: {{ cran_mirror }}

repo:
  bbs:
    name: BBS
    github: https://github.com/Bioconductor/BBS
    branch: devel
  manifest:
    name: manifest
    github: https://git.bioconductor.org/admin/manifest
    branch: {{ current_branch }}
