install_libgsl:
  pkg.installed:
    - pkgs:
      - libgsl23
      - libgslcblas0


install_viennarna_deb:
  cmd.run:
    - name: wget https://www.tbi.univie.ac.at/RNA/download/ubuntu/ubuntu_20_04/viennarna_2.4.17-1_amd64.deb && dpkg -i viennarna_2.4.17-1_amd64.deb
