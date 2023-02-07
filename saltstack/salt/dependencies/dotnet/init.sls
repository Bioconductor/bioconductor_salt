# Needed by BioC rmspc

{% set machine = salt["pillar.get"]("machine") %}
{%- if grains["osarch"] == "arm64" %}
{% set download_url = machine.dependencies.arm64.dotnet %}
{% else %}
{% set download_url = machine.dependencies.intel.dotnet %}
{%- endif %}
{% set download = machine.dependencies.dotnet.split("/")[-1] %}

{%- if machine.r_path is defined %}
{% set r_path = machine.r_path %}
{% else %}
{% set r_path = '' %}
{%- endif %}

{%- if grains['os'] == 'Ubuntu' %}
install_dotnet:
  cmd.run:
    - name: curl -LO packages-microsoft-prod.deb {{ machine.dependencies.dotnet }} && dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb

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
    - name: curl -LO {{ machine.dependencies.dotnet }}
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - runas: biocbuild

install_dotnet:
  cmd.run:
    - name: installer -pkg {{ download }} -target /
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - require:
      - cmd: download_dotnet
{%- endif %}

test_R_CMD_build_rmspc:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/rmspc
        {{ r_path }}R CMD build rmspc
        ls rmspc*tar.gz | {{ r_path }}R CMD check --no-vignettes
    - cwd: /tmp
    - runas: biocbuild
    - require:
      - cmd: install_dotnet
