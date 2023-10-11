# Needed for CRAN ncdf4, BioC mzR

{% set machine = salt["pillar.get"]("machine") %}
{%- if grains["osarch"] == "arm64" %}
{% set netcdf_url = machine.dependencies.arm64.netcdf %}
{% set hdf5_url = machine.dependencies.arm64.hdf5 %}
{% else %}
{% set netcdf_url = machine.dependencies.intel.netcdf %}
{% set hdf5_url = machine.dependencies.intel.hdf5 %}
{%- endif %}
{% set netcdf = netcdf_url.split("/")[-1] %}
{% set hdf5 = hdf5_url.split("/")[-1] %}

download_netcdf:
  cmd.run:
    - name: curl -LO {{ netcdf_url }}
    - cwd: /tmp
    - user: {{ machine.user.name }}

untar_netcdf:
  cmd.run:
    - name: tar xvfJ /tmp/{{ netcdf }} -C /
    - cwd: /usr/local
    - user: {{ machine.user.name }}
    - require:
      - cmd: download_netcdf

download_hdf5:
  cmd.run:
    - name: curl -LO {{ hdf5_url }}
    - cwd: /tmp
    - user: {{ machine.user.name }}

untar_hdf5:
  cmd.run:
    - name: tar xvfJ /tmp/{{ hdf5 }} -C /
    - cwd: /usr/local
    - require:
      - cmd: download_hdf5

fix_/usr/local_permissions_netcdf_hdf5:
  cmd.run:
    - name: |
        chown -R {{ machine.user.name }}:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive

test_ncdf4:
  cmd.run:
    - name: Rscript -e 'install.packages("ncdf4", type="source", repos="https://cran.r-project.org")'
    - runas: {{ machine.user.name }}
    - require:
      - cmd: fix_/usr/local_permissions_netcdf_hdf5
