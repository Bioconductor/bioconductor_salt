# Needed for BioC LowMACA

{% set machine = salt["pillar.get"]("machine") %}
{% set download = machine.dependencies.clustal_omega.split("/")[-1] %}

download_clustal_omega:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.clustal_omega }}
    - cwd: /tmp
    - user: {{ machine.user.name }}

change_clustal_omega_permissions:
  cmd.run:
    - name: chmod +x {{ download }}
    - cwd: /tmp
    - require:
      - cmd: download_clustal_omega

move_clustal_omega:
  cmd.run:
    - name: mv -i {{ download }} /usr/local/bin
    - cwd: /tmp
    - require:
      - cmd: change_clustal_omega_permissions

symlink_clustal_omega:
  file.symlink:
    - name: /usr/local/bin/clustalo
    - target: /usr/local/bin/{{ download }}
    - require:
      - cmd: move_clustal_omega

test_R_CMD_build_LowMACA_for_clustal_omega:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/LowMACA
        R CMD build LowMACA
    - cwd: /tmp
    - runas: {{ machine.user.name }}
    - require:
      - file: symlink_clustal_omega
