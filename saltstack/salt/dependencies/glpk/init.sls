# Needed for BioC MMUPHin

{% set machine = salt["pillar.get"]("machine") %}
{% set download_url = machine.dependencies.glpk %}
{% set download = download_url.split("/")[-1] %}

download_glpk:
  cmd.run:
    - name: curl -LO {{ download_url }}
    - cwd: /tmp
    - user: {{ machine.user.name }}

untar_glpk:
  cmd.run:
    - name: tar xf /tmp/{{ download }} -C /
    - user: {{ machine.user.name }}
    - require:
      - cmd: download_glpk

fix_/usr/local_permissions_glpk:
  cmd.run:
    - name: |
        chown -R {{ machine.user.name }}:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive

reinstall_igraph:
  cmd.run:
    - name: Rscript -e 'BiocManager::install("igraph", force=TRUE)'
    - runas: {{ machine.user.name }}
    - require:
      - cmd: fix_/usr/local_permissions_glpk

test_bioc_install_MMUPHin:
  cmd.run:
    - name: Rscript -e 'library(igraph); cluster_optimal(make_graph("Zachary"))'
    - runas: {{ machine.user.name }}
    - require:
      - cmd: reinstall_igraph
