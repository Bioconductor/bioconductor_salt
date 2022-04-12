# Needed by BioC inferrnal

brew_tap_brewsci/bio:
  cmd.run:
    - name: brew tap brewsci/bio
    - runas: biocbuild

brew_install_infernal:
  cmd.run:
    - name: brew install infernal
    - runas: biocbuild
    - require:
      - cmd: brew_tap_brewsci/bio

test_R_CMD_build_inferrnal:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/inferrnal
        R CMD build inferrnal
    - cwd: /tmp
    - runas: biocbuild
    - require:
      - cmd: brew_install_infernal
