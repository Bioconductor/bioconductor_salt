# Copy salt files into /srv/salt
# Place biocbuild ssh key into /srv/salt/common/files
# Place an authorized_keys file with core team member public keys in /srv/salt/common/files

{% set machine = salt["pillar.get"]("machine") %}
{% set build = salt["pillar.get"]("build") %}
{% set repo = salt["pillar.get"]("repo") %}
{% set bbs_bioc = machine.user.home ~ "/" ~ machine.user.name ~ "/bbs-" ~ "%.2f" | format(build.version) ~ "-bioc" %}


{%- if grains['osfinger'] == 'Ubuntu-24.04' %}
create_virtualenv:
  cmd.run:
    - name: {{ bbs_bioc }}/R/bin/Rscript -e "BiocManager::install('reticulate'); reticulate::py_config()"
    - runas: {{ machine.user.name }}
{% else %}
update_pip:
  cmd.run:
    - name: pip install --upgrade pip

install_pip_pkgs:
  cmd.run:
    - name: python3 -m pip install $(cat /home/{{ machine.user.name }}/{{ repo.bbs.name }}/{{ grains["os"] }}-files/{{ grains["osrelease"] }}/pip_*.txt | awk '/^[^#]/ {print $1}')
{% endif %}
