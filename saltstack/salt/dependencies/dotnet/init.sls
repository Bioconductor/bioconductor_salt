# Needed by BioC rmspc

{% set machine = salt["pillar.get"]("machine") %}
{%- if grains["os"] == "MacOS" %}
{%- if grains["osarch"] == "arm64" %}
{% set download_url = machine.dependencies.arm64.dotnet %}
{% else %}
{% set download_url = machine.dependencies.intel.dotnet %}
{%- endif %}
{% set download = download_url.split("/")[-1] %}
{% set r_path = "" %}
{% else %}
{% set machine = salt["pillar.get"]("machine") %}
{% set build = salt["pillar.get"]("build") %}
{% set r_path  = machine.user.home ~ "/" ~ machine.user.name ~ "/bbs-" ~ "%.2f" | format(build.version) ~ "-bioc/" %}
{%- endif %}

{%- if grains["os"] == "MacOS" %}
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
{% else %}
add_backports_repository:
  pkgrepo.managed:
    - name: ppa:dotnet/backports

install_dotnet:
  pkg.installed:
    - name: aspnetcore-runtime-9.0
{%- endif %}
install_rmspc_dependencies:
  cmd.run:
    - name: {{ r_path }}R/bin/Rscript -e "BiocManager::install(c('processx', 'GenomicRanges', 'stringr'), force=TRUE)"
    - require:
      - cmd: install_dotnet

test_R_CMD_build_rmspc:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/rmspc
        {{ r_path }}R/bin/Rscript -e "BiocManager::install('rmspc')"
        {{ r_path }}R CMD build rmspc
    - cwd: /tmp
    - runas: {{ machine.user.name }}
    - require:
      - cmd: install_dotnet
