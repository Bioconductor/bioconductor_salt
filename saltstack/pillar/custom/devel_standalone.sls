{# Custom Settings #}

{% set branch = 'devel' %} {# Use 'release' or 'devel' #}
{% set version = '3.19' %}
{% set environment = 'dev' %} {# Use 'dev' or 'prod' #}
{% set r_download = 'https://stat.ethz.ch/R/daily/R-devel.tar.gz' %}
{% set r_version = 'R-4.4' %}
{% set r_previous_version = 'R-4.3' %}
{% set cycle = 'patch' %} {# Use 'devel' for Spring to Fall, 'patch' for Fall to Spring #}
{% set name = 'bbs-machine' %}
{% set immunespace_pwd = '' %}
{% set create_users = False %}
{% set machine_type = 'standalone' %}
