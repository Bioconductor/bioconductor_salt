# Needed for BioC ChemmineOB

{% set machine = salt["pillar.get"]("machine") %}

brew_open_babel:
  cmd.run:
    - name: brew install eigen open-babel boost
    - runas: biocbuild

symlink_open_babel:
  cmd.run:
    - name: ln -s ../Cellar/open-babel/$(brew info openbabel | grep "openbabel: stable" | awk '{print $3'})/lib openbabel3
    - cwd: /usr/local/lib 
    - user: biocbuild
    - group: staff

test_bioc_install_ChemmineOB:
  cmd.run:
    - name: Rscript -e 'library(BiocManager); BiocManager::install("ChemmineOB", type="source")'
    - require:
      - cmd: symlink_open_babel
