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

export_openbabel.pc_to_PKG_CONFIG_PATH:
  file.append:
    - name: /etc/profile
    - text: export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/openbabel3/pkgconfig

test_bioc_install_ChemmineOB:
  cmd.run:
    - name: Rscript -e 'library(BiocManager); BiocManager::install("ChemmineOB", type="source")'
    - runas: {{ machine.user.name }}
