{% set machine = salt["pillar.get"]("machine") %}

{%- if grains["osarch"]== "arm64" %}
{% set download_url = machine.dependencies.java_aarch64 %}
{% else %}
{% set download_url = machine.dependencies.java_x64 %}
{%- endif %}

{% set download = java_url.split("/")[-1] %}
{% set java = download.split("_")[0] %}

download_java:
  cmd.run:
    - name: curl -LO {{ download_url }}
    - cwd:  {{ machine.user.home }}/biocbuild/Downloads
    - runas: biocbuild

{# NOTE: May fail but will still untar files #}
untar_java:
  cmd.run:
    - name: tar zxvf {{ machine.user.home }}/biocbuild/Downloads/{{ download }} -C /usr/local
    - require:
      - cmd: download_java

fix_/usr/local_permissions_java:
  cmd.run:
    - name: |
        chown -R biocbuild:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive

symlink_java:
  cmd.run:
    - name: |
        ln -s ../{{ java }}.jdk/Contents/Home/bin/java
        ln -s ../{{ java }}.jdk/Contents/Home/bin/javac
        ln -s ../{{ java }}.jdk/Contents/Home/bin/jar
    - cwd: /usr/local/bin 
    - require:
      - cmd: fix_/usr/local_permissions_java

set_JAVA_HOME:
  file.append:
    - name: /etc/profile
    - text: export JAVA_HOME=/usr/local/{{ java }}.jdk/Contents/Home

configure_R_to_use_Java:
  cmd.run:
    - name: R CMD javareconf
    - onlyif: which R
    - require:
      - file: set_JAVA_HOME
