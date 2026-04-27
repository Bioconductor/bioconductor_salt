{# Custom Settings #}

{% set branch = 'release' %} {# Use 'release' or 'devel' #}
{% set version = '3.23' %}
{% set r_download = 'https://cran.r-project.org/src/base/R-4/R-4.6.0.tar.gz' %}
{% set r_version = 'R-4.6' %}
{% set r_previous_version = 'R-4.5' %}
{% set cran_mirror = 'https://cloud.r-project.org/' %}
{% set cycle = 'devel' %} {# Use 'devel' for Spring to Fall, 'patch' for Fall to Spring #}
{% set name = 'bbs-machine' %}
{% set create_users = False %}
{% set machine_type = 'standalone' %}
{% set gpu = False %}
