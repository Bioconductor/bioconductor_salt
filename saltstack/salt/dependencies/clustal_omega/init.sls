# Needed for BioC LowMACA

{% set machine = salt["pillar.get"]("machine") %}
{% set downloaded_clustal_omega = machine.downloads.clustal_omega.split("/")[-1] %}

download_jags:
  cmd.run:
    - name: curl -L {{ machine.downloads.clustal_omega }}
    - cwd:  {{ machine.user.home }}/Downloads
    - user: biocbuild

change_clustal_omega_permissions:
  cmd.run:
    - name: chmod +x {{ downloaded_clustal_omega }} 
    - cwd:  {{ machine.user.home }}/Downloads
    - require:
      - cmd: download_clustal_omega

move_clustal_omega:
  cmd.run:
    - name: mv -i {{ downloaded_clustal_omega }} /usr/local/bin 
    - cwd:  {{ machine.user.home }}/Downloads
    - require:
      - cmd: change_clustal_omega_permissions

symlink_clustal_omega:
  file.symlink:
    - name: clustalo
    - target: {{ downloaded_clustal_omega }} 
    - cwd: /usr/local/bin
    - require:
      - cmd: move_clustal_omega

test_R_CMD_build_LowMACA_for_clustal_omega:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/LowMACA
        R CMD build LowMACA
    - cwd: /tmp
