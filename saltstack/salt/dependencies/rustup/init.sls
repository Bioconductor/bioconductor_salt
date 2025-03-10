# Required for BioC CellBarcode

curl_rustup_sh:
  cmd.run:
    - name: curl https://sh.rustup.rs -sSf | sh
    - runas: biocbuild
