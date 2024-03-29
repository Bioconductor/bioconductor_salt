# Needed for BioC Travel
# May need to enable support for third party kernel extensions.
# See https://github.com/macfuse/macfuse/wiki/Getting-Started

{% set machine = salt["pillar.get"]("machine") %}
{% set download = machine.dependencies.macfuse.split("/")[-1] %}

download_macfuse:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.macfuse }}
    - cwd: /tmp
    - user: {{ machine.user.name }}

install_macfuse:
  cmd.run:
    - name: |
        hdiutil attach {{ download }}
        installer -pkg "/Volumes/macFUSE/Install macFUSE.pkg" -target /
        hdiutil detach /Volumes/macFUSE
    - cwd: /tmp
    - require:
      - cmd: download_macfuse

test_install_bioc_Travel:
  cmd.run:
    - name: Rscript -e 'library(BiocManager); BiocManager::install("Travel", type="source")'
    - runas: {{ machine.user.name }}
    - require:
      - cmd: install_macfuse
