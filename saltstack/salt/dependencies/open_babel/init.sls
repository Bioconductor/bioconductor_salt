# Needed for BioC ChemmineOB

brew_open_babel:
  cmd.run:
    - name: brew install eigen open-babel boost
    - runas: biocbuild

symlink_open_babel:
  cmd.run:
    - name: |
        openbabel_path=$(brew info open-babel | grep "/usr/local" | awk '{print $1}')
        ln -s $openbabel_path/lib openbabel3
    - cwd: /usr/local/lib
    - runas: biocbuild
    - require:
      - cmd: brew_open_babel

test_bioc_install_ChemmineOB:
  cmd.run:
    - name: Rscript -e 'library(BiocManager); BiocManager::install("ChemmineOB", type="source")'
    - require:
      - cmd: symlink_open_babel
