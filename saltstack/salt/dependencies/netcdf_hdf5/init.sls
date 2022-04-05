# Needed for CRAN ncdf4, BioC mzR

{% set machine = salt["pillar.get"]("machine") %}
{% set netcdf = machine.dependencies.netcdf.split("/")[-1] %}
{% set hdf5 = machine.dependencies.hdf5.split("/")[-1] %}

download_netcdf:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.netcdf }}
    - cwd:  {{ machine.user.home }}/biocbuild/Downloads
    - user: biocbuild

untar_netcdf:
  cmd.run:
    - name: tar xvfJ {{ machine.user.home }}/biocbuild/Downloads/{{ netcdf }} -C /
    - cwd: /usr/local
    - user: biocbuild
    - require:
      - cmd: download_netcdf

download_hdf5:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.hdf5 }}
    - cwd:  {{ machine.user.home }}/biocbuild/Downloads
    - user: biocbuild

untar_hdf5:
  cmd.run:
    - name: tar xvfJ {{ machine.user.home }}/biocbuild/Downloads/{{ hdf5 }} -C /
    - cwd: /usr/local
    - user: biocbuild
    - require:
      - cmd: download_hdf5

fix_/usr/local_permissions_netcdf_hdf5:
  cmd.run:
    - name: |
        chown -R biocbuild:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive
    - require:
      - cmd: untar_netcdf
      - cmd: untar_hdf5

test_ncdf4:
  cmd.run:
    - name: Rscript -e 'install.packages("ncdf4", type="source", repos="https://cran.r-project.org")'
    - require:
      - cmd: fix_/usr/local_permissions_netcdf_hdf5
