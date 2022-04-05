# Needed for BioC Travel

{% set machine = salt["pillar.get"]("machine") %}
{% set download = machine.dependencies.macfuse.split("/")[-1] %}
{% set macfuse = macfuse[-4] %}

download_macfuse:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.macfuse }}
    - cwd:  {{ machine.user.home }}/Downloads
    - user: biocbuild

install_macfuse:
  cmd.run:
    - name: |
        hdiutil attach {{ download }}
        installer -pkg /Volumes/{{ macfuse }}/{{macfuse }}.pkg -target /
        hdiutil detach /Volumes/{{ macfuse }}
    - require:
      - cmd: download_macfuse

test_install_bioc_Travel:
  cmd.run:
    - name: Rscript -e 'library(BiocManager); BiocManager::install("Travel", type="source")'
    - require:
      - cmd: install_macfuse
