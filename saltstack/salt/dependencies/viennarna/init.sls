# Needed by BioC GeneGA

{% set machine = salt["pillar.get"]("machine") %}
{% set download = machine.dependencies.viennarna.split("/")[-1] %}
{% set viennarna_version = download[10:-11] %}
{%- if machine.r_path is defined %}
{% set r_path = machine.r_path %}
{% else %}
{% set r_path = '' %}
{%- endif %}

{%- if grains['os'] == 'Ubuntu' %}
install_libgsl:
  pkg.installed:
    - pkgs:
      - libgsl23
      - libgslcblas0

install_viennarna:
  cmd.run:
    - name: wget {{ machine.dependencies.viennarna }} && dpkg -i {{ download }} 

{%- elif grains['os'] == 'MacOS' %}
download_viennarna:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.viennarna }} 
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - runas: biocbuild

install_viennarna:
  cmd.run:
    - name: |
        hdiutil attach {{ download }}
        installer -pkg "/Volumes/ViennaRNA {{ viennarna_version }}/ViennaRNA Package {{ viennarna_version }} Installer.pkg" -target /
        hdiutil detach "/Volumes/ViennaRNA {{ viennarna_version }}"
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - require:
      - cmd: download_viennarna

fix_/usr/local_permissions_viennarna:
  cmd.run:
    - name: |
        chown -R biocbuild:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive
    - require:
      - cmd: install_viennarna
{%- endif %}

test_R_CMD_build_GeneGA:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/GeneGA
        {{ r_path }}R CMD build GeneGA
    - cwd: /tmp
    - runas: biocbuild
    - require:
      - cmd: install_viennarna
