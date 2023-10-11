{# Custom Settings #}

{% set branch = 'devel' %} {# Use 'release' or 'devel' #}
{% set version = '3.18' %}
{% set environment = 'dev' %} {# Use 'dev' or 'prod' #}
{% set r_download = 'https://cran.r-project.org/src/base/R-4/R-4.3.1.tar.gz' %}
{% set r_version = 'R-4.3' %}
{% set r_previous_version = 'R-4.2' %}
{% set cycle = 'devel' %} {# Use 'devel' for Spring to Fall, 'patch' for Fall to Spring #}
{% set name = 'bbs-machine' %}
{% set immunespace_pwd = '' %}
{% set create_users = False %}
{% set machine_type = 'standalone' %}
