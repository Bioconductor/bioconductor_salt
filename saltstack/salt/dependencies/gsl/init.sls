# Needed for BioC GLAD

{% set machine = salt["pillar.get"]("machine") %}
{% set download = machine.dependencies.gsl.split("/")[-1] %}

download_gsl:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.gsl }}
    - cwd:  {{ machine.user.home }}/biocbuild/Downloads
    - user: biocbuild

untar_gsl:
  cmd.run:
    - name: tar xvfJ {{ machine.user.home }}/biocbuild/Downloads/{{ download }} -C /
    - user: biocbuild
    - require:
      - cmd: download_gsl

fix_/usr/local_permissions_gsl:
  cmd.run:
    - name: |
        chown -R biocbuild:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive

test_bioc_install_GLAD:
  cmd.run:
    - name: Rscript -e 'library(BiocManager); BiocManager::install("GLAD", type="source")'
    - require:
      - cmd: fix_/usr/local_permissions_gsl
