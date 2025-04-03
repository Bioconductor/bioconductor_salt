{# Custom Settings #}

{% set branch = 'devel' %} {# Use 'release' or 'devel' #}
{% set version = '3.22' %}
{% set environment = 'dev' %} {# Use 'dev' or 'prod' #}
{% set r_download = 'https://stat.ethz.ch/R/daily/R-devel.tar.gz' %}
{% set r_version = 'R-4.5' %}
{% set r_previous_version = 'R-4.4' %}
{% set cran_mirror = 'https://cloud.r-project.org/' %}
{% set cycle = 'devel' %} {# Use 'devel' for Spring to Fall, 'patch' for Fall to Spring #}
{% set name = 'bbs-machine' %}
{% set create_users = False %}
{% set machine_type = 'standalone' %}
