{# Change configuration as needed #}

{% set branch = 'release' %} {# Use 'release' or 'devel' #}
{% set version = '3.14' %} 
{% set environment = 'dev' %} {# Use 'dev' or 'prod' #}
{% set r_download = 'https://cran.r-project.org/src/base/R-4/R-4.1.1.tar.gz' %}
{% set r_version = 'R-4.1.1' %}
{% set cycle = 'patch' %} {# Use 'devel' for Spring to Fall, 'patch' for Fall to Spring #}
{% set name = 'nebbiolo2' %}
{% set immunespace_pwd = 'CHANGE' %}
{% set biocbuild_password = 'CHANGE' %}
{% set biocbuild_key = 'salt://common/files/id_rsa' %}
{% set biocbuild_authorized_key = 'CHANGE' %}
{% set biocpush_password = 'CHANGE' %}
{% set biocpush_key = 'salt://common/files/id_rsa' %}
{% set biocpush_authorized_key = 'CHANGE' %}

{# See machine.users below to add more users #}

build:
  branch: {{ branch }}
  cycle: {{ cycle }}
  version: {{ version }}
  types:
    - bioc                  {# always required #}
    - workflows
    - books
    - data-experiment
    - data-annotation
    #- bioc-longtests
  cron:
    user: biocbuild
    path: /usr/local/bin:/usr/bin:/bin
    jobs:
      - name: bioc_prerun
        command: /bin/bash --login -c "cd /home/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./prerun.sh >>/home/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-prerun.log 2>&1"
        minute: 50
        hour: 14
        daymonth: "*"
        month: "*"
        dayweek: "0-5"
        comment: "BIOC {{ version }} SOFTWARE BUILDS"
        commented: True 
      - name: bioc_run
        command: /bin/bash --login -c "cd /home/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./run.sh >>/home/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-run.log 2>&1"
        minute: 00
        hour: 16
        daymonth: "*"
        month: "*"
        dayweek: "0-5"
        comment: "BIOC {{ version }} SOFTWARE BUILDS"
        commented: True 
      - name: bioc_postrun
        command: /bin/bash --login -c "cd /home/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./postrun.sh >>/home/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-postrun.log 2>&1"
        minute: 00
        hour: 12
        daymonth: "*"
        month: "*"
        dayweek: "1-6"
        comment: "BIOC {{ version }} SOFTWARE BUILDS"
        commented: True 

machine:
  name: {{ name }} 
  env: {{ environment }}
  os:
    name: Ubuntu
    version: 20.04
  ip: 127.0.1.1
  cores: 8 {# to find out available cores, run cat /proc/cpuinfo | grep processor | wc -l #}
  type: primary
  groups: 
    - biocbuild
    - biocpush
    - bioconductor
  users:
    - name: biocbuild
      key: {{ biocbuild_key }}
      password: {{ biocbuild_password }}
      groups:
        - biocbuild
      authorized_keys:
        - {{ biocbuild_authorized_key }} 
    - name: biocpush
      key: {{ biocpush_key }}
      password: {{ biocpush_password }}
      groups:
        - biocpush
      authorized_keys:
        - {{ biocpush_authorized_key }} 
      {# Add more users using the same pattern as above
    - name: member
      pub-key: "ssh-dss AAAAB3NzaCL0sQ9fJ5bYTEyY== user@domain" 
      password: some password
      groups:
        - sudo
        - bioconductor
      #}

r:
  download: {{ r_download }} 
  version: {{ r_version }}

repo:
  bbs:
    name: BBS
    github: https://github.com/Bioconductor/BBS
    branch: master
  manifest:
    name: manifest
    github: https://git.bioconductor.org/admin/manifest
    branch: master

{# Bioc package dependencies #}

dependencies:
  bibtex: True                          {# for bioc destiny #}
  ensemblvep: True                      {# for bioc ensemblVEP and MMAPPR2 #}
  viennarna: True                       {# for bioc GeneGA #}
  libsbml_cflags_libsbml_libs: True     {# for bioc rsbml #}
  immunespace: True                     {# for bioc ImmuneSpaceR #}
  xmlsimple: True                       {# for bioc LowMACA #}
  dotnet: True                          {# for bioc rmspc #}

immunespace:
  login: bioc@immunespace.org
  pwd: {{ immunespace_pwd }}

dotnet:
  url: https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
