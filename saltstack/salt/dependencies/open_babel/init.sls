# Needed for BioC ChemmineOB

{% set machine = salt["pillar.get"]("machine") %}

brew_open_babel:
  cmd.run:
    - name: brew install eigen open-babel boost
    - runas: {{ machine.user.name }}

symlink_open_babel:
  cmd.run:
    - name: |
        openbabel_path=$(brew info open-babel | grep "/usr/local" | awk '{print $1}')
        ln -s $openbabel_path/lib openbabel3
    - cwd: /usr/local/lib
    - runas: {{ machine.user.name }}
    - require:
      - cmd: brew_open_babel

test_bioc_install_ChemmineOB:
  cmd.run:
    - name: Rscript -e 'library(BiocManager); BiocManager::install("ChemmineOB", type="source")'
    - runas: {{ machine.user.name }}
    - require:
      - cmd: symlink_open_babel
