# Needed by BioC GeneGA
# Mac Only

{% set machine = salt["pillar.get"]("machine") %}
{%- if machine.r_path is defined %}
{% set r_path = machine.r_path %}
{% else %}
{% set r_path = "" %}
{%- endif %}

{%- if grains["osarch"] == "arm64" %}
{% set download_url = machine.dependencies.arm64.viennarna %}
{% else %}
{% set download_url = machine.dependencies.intel.viennarna %}
{%- endif %}

{% set download = download.split("/")[-1] %}
download_viennarna:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.viennarna }} 
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - runas: biocbuild

{%- if grains["osarch"] == "arm64" %}
{% set perl_version = perl -v | grep version | awk -F" " "{print $9}" %}
{% set cpath = machine.sdk.path ~ "/System/Library/Perl/" ~ perl_verison[2:-3] ~ "/darwin-thread-multi-2level/CORE/EXTERN.h" %}

untar_viennarna:
  cmd.run:
    - name: tar xvfJ {{ machine.user.home }}/biocbuild/Downloads/{{ download }}
    - require:
      - cmd.run: download_viennarna

configure_compile_install_viennarna:
  cmd.run:
    - name: export CPATH={{ cpath }} ./configure && make && make install
    - require:
      - cmd.run: untar_vienna

{%- else %}
{% set viennarna_version = download[10:-11] %}

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
