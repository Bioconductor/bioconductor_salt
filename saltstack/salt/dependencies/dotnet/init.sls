# Needed by BioC rmspc

{% set machine = salt["pillar.get"]("machine") %}
{% set download = machine.dependencies.dotnet.split("/")[-1] %}

{%- if machine.r_path is defined %}
{% set r_path = machine.r_path %}
{% else %}
{% set r_path = '' %}
{%- endif %}

{%- if grains['os'] == 'Ubuntu' %}
wget_deb:
  cmd.run:
    - name: wget {{ download }} -O packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb

apt_update:
  cmd.run:
    - name: apt-get update

install_apt-transport-https_aspnetcore-runtime:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - aspnetcore-runtime-5.0
{% elif grains['os'] == 'MacOS' %}
download_dotnet:
  cmd.run:
    - name: curl -O {{ machine.dependencies.dotnet}} 
    - cwd: {{ machine.user.home }}/Downloads
    - runas: biocbuild

install_dotnet:
  cmd.run:
    - name: installer -pkg {{ download }} -target /
    - cwd: {{ machine.user.home }}/Downloads
    - runas: biocbuild
    - require:
      - cmd: download_dotnet
{%- endif %}

test_R_CMD_build_rmspc:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/rmspc
        {{ r_path }}/R CMD build rmspc
        ls rmspc*tar.gz | {{ r_path }}/R CMD check --no-vignettes
    - cwd: /tmp
    - require:
      - file: install_dotnet
