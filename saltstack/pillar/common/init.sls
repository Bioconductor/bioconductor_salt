{% from '../custom/init.sls' import branch, version, environment,
   r_download, r_version, r_previous_version, cycle, name,
   immunespace_pwd, biocbuild_password, biocbuild_key,
   biocbuild_authorized_key, biocpush_password, biocpush_key,
   biocpush_authorized_key, create_users %}

{%- if branch == 'release' %}
{% set current_branch = 'RELEASE_' ~ version.replace(".", "_") %}
{% else %}
{% set current_branch = 'master' %}
{%- endif %}

{%- if grains['os'] == 'Ubuntu' %}
{% set user_home = '/home' %}
{% set shell = '/usr/bin/bash' %}
{% set slash = '/' %}
{% set machine_type = 'primary' %}
{% elif grains['os'] == 'MacOS' %}
{% set user_home = '/Users' %}
{% set shell = '/usr/bin/sh' %}
{% set slash = '/' %}
{% set machine_type = 'secondary' %}
{%- endif %}

{# See machine.users below to add more users #}

build:
  branch: {{ branch }}
  cycle: {{ cycle }}
  version: {{ version }}
  types:
    - bioc                  {# always required #}
  cron:
    user: biocbuild
    path: /usr/local/bin:/usr/bin:/bin
    jobs:
      - name: bioc_prerun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./prerun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-prerun.log 2>&1"
        minute: 55
        hour: 13
        daymonth: "*"
        month: "*"
        dayweek: "0-5"
        comment: "BIOC {{ version }} SOFTWARE BUILDS prerun"
        commented: True
      - name: bioc_run
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./run.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-run.log 2>&1"
        minute: 00
        hour: 15
        daymonth: "*"
        month: "*"
        dayweek: "0-5"
        comment: "BIOC {{ version }} SOFTWARE BUILDS run"
        commented: True
      - name: bioc_postrun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./postrun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-postrun.log 2>&1"
        minute: 00
        hour: 11
        daymonth: "*"
        month: "*"
        dayweek: "1-6"
        comment: "BIOC {{ version }} SOFTWARE BUILDS postrun"
        commented: True
      - name: bioc_notify
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./stage7-notify.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-notify.log 2>&1"
        minute: 00
        hour: 13
        daymonth: "*"
        month: "*"
        dayweek: "3"
        comment: "BIOC {{ version }} SOFTWARE BUILDS notify"
        commented: True

machine:
  name: {{ name }}
  env: {{ environment }}
  slash: {{ slash }}
  ip: 127.0.1.1
  cores: 8 {# to find out available cores, run cat /proc/cpuinfo | grep processor | wc -l #}
  type: {{ machine_type }}
  create_users: {% if create_users is defined %}{{ create_users }}{% else %}True{% endif %}
  {%- if grains['os'] == 'Ubuntu' %}
  r_path: {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/R/bin/
  groups: 
    - biocbuild
    {%- if machine_type == 'primary' %}
    - biocpush
    - bioconductor
    {%- endif %}
  {% endif %}
  user:
    home: {{ user_home }}
    shell: {{ shell }}
  users:
    - name: biocbuild
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
    {# Add more users using the same pattern as above
    - name: member
      pub-key: "ssh-dss AAAAB3NzaCL0sQ9fJ5bYTEyY== user@domain"
      password: PASSWORD
      groups:
        - sudo
        - bioconductor
    #}

r:
  download: {{ r_download }}
  version: {{ r_version }}
  previous_version: {{ r_previous_version }}

repo:
  bbs:
    name: BBS
    github: https://github.com/Bioconductor/BBS
    branch: master
  manifest:
    name: manifest
    github: https://git.bioconductor.org/admin/manifest
    branch: {{ current_branch }}

{# Bioc package dependencies #}

immunespace:
  login: bioc@immunespace.org
  pwd: {{ immunespace_pwd }}
