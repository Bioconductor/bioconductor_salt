# Needed for quarto

{% set machine = salt["pillar.get"]("machine") %}
{% set download = machine.dependencies.quarto.split("/")[-1] %}
{% set quarto = download[:-4] %}

download_quarto:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.quarto }}
    - cwd: /tmp
    - user: {{ machine.user.name }}

{%- if grains['os'] == 'Ubuntu' %}
install_quarto:
  cmd.run:
    - name: dpkg -i {{ quarto }}.deb
    - require:
      - cmd: download_quarto
{% else %}
install_quarto:
  cmd.run:
    - name: installer -pkg /tmp/{{ quarto }}.pkg -target /
    - require:
      - cmd: download_quarto

fix_/usr/local_permissions_quarto:
  cmd.run:
    - name: |
        chown -R {{ machine.user.name }}:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive
    - require:
      - cmd: install_quarto
{% endif %}

test_quarto_install:
  cmd.run:
    - name: Rscript -e 'install.packages("quarto", type="source", repos="https://cran.r-project.org")'
    - runas: {{ machine.user.name }}
