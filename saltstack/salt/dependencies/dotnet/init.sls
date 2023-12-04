# Needed by BioC rmspc

{% set machine = salt["pillar.get"]("machine") %}
{%- if grains["os"] == "MacOS" %}
{%- if grains["osarch"] == "arm64" %}
{% set download_url = machine.dependencies.arm64.dotnet %}
{% else %}
{% set download_url = machine.dependencies.intel.dotnet %}
{%- endif %}
{% set download = download_url.split("/")[-1] %}
{%- endif %}

{%- if machine.r_path is defined %}
{% set r_path = machine.r_path %}
{% else %}
{% set r_path = '' %}
{%- endif %}

{%- if grains['os'] == 'Ubuntu' %}
install_dotnet:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.dotnet }} && dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb
    - cwd: /tmp
    - runas: root

apt_update:
  cmd.run:
    - name: apt-get update

install_aspnetcore-runtime:
  pkg.installed:
    - pkgs:
      - aspnetcore-runtime-6.0
{% elif grains['os'] == 'MacOS' %}
download_dotnet:
  cmd.run:
    - name: curl -LO {{ download_url }}
    - cwd: /tmp
    - runas: {{ machine.user.name }}

install_dotnet:
  cmd.run:
    - name: installer -pkg {{ download }} -target /
    - cwd: /tmp
    - require:
      - cmd: download_dotnet
{%- endif %}

install_rmspc_dependencies:
  cmd.run:
    - name: {{ r_path }}Rscript -e "BiocManager::install(c('processx', 'GenomicRanges', 'stringr'))" 
    - require:
      - cmd: install_dotnet

test_R_CMD_build_rmspc:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/rmspc
        {{ r_path }}R CMD build rmspc
    - cwd: /tmp
    - runas: {{ machine.user.name }}
    - require:
      - cmd: install_dotnet
