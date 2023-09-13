# Needed for BioC GLAD

{% set machine = salt["pillar.get"]("machine") %}
{%- if grains["osarch"] == "arm64" %}
{% set download_url = machine.dependencies.arm64.gsl %}
{% else %}
{% set download_url = machine.dependencies.intel.gsl %}
{%- endif %}
{% set download = download_url.split("/")[-1] %}

download_gsl:
  cmd.run:
    - name: curl -LO {{ download_url }}
    - cwd: /tmp
    - user: {{ machine.user.name }}

untar_gsl:
  cmd.run:
    - name: tar xvfJ /tmp/{{ download }} -C /
    - user: {{ machine.user.name }}
    - require:
      - cmd: download_gsl

fix_/usr/local_permissions_gsl:
  cmd.run:
    - name: |
        chown -R {{ machine.user.name }}:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive

test_bioc_install_GLAD:
  cmd.run:
    - name: Rscript -e 'library(BiocManager); BiocManager::install("GLAD", type="source")'
    - runas: {{ machine.user.name }}
    - require:
      - cmd: fix_/usr/local_permissions_gsl
