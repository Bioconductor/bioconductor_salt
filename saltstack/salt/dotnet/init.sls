{% set dotnet = salt["pillar.get"]("dotnet") %}

wget_deb:
  cmd.run:
    - name: wget {{ dotnet.url }} -O packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb

apt_update:
  cmd.run:
    - name: apt-get update

install_apt-transport-https_aspnetcore-runtime:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - aspnetcore-runtime-5.0
