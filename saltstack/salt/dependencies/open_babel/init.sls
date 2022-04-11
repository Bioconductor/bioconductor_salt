# Needed for BioC ChemmineOB

remove_x11_symlink:
  cmd.run:
    - name: /usr/local/include/X11

brew_open_babel:
  cmd.run:
    - name: brew install eigen open-babel boost
    - runas: biocbuild

symlink_open_babel:
  cmd.run:
    - name: |
        openbabel_version=$(brew info open-babel | grep "open-babel: stable" | awk '{print $3}')
        ln -s /usr/local/lib/Cellar/open-babel/$openbabel_version/lib openbabel3
    - runas: biocbuild
    - require:
      - cmd: brew_open_babel

test_bioc_install_ChemmineOB:
  cmd.run:
    - name: Rscript -e 'library(BiocManager); BiocManager::install("ChemmineOB", type="source")'
    - require:
      - cmd: symlink_open_babel
