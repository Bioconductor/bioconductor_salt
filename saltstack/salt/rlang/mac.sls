{% set build = salt["pillar.get"]("build") %}
{% set machine = salt["pillar.get"]("machine") %}
{% set r = salt["pillar.get"]("r") %}
{% set downloaded_file  = r.download.split("/")[-1] %}
{%- if grains["osarch"] == "arm64" %}
{% set subpath = "arm64" %}
{%- else %}
{% set subpath = "x86_64" %}
{%- endif %}

remove_old_r:
  file.absent:
    - name: /Library/Frameworks/R.framework

get_R_pkg:
  cmd.run:
    - name: curl -O {{ r.download }}
    - cwd: {{ machine.user.home }}/{{ machine.user.name }}/Downloads
    - require:
      - file: remove_old_r

install_R:
  cmd.run:
    - name: installer -pkg {{ downloaded_file }} -target /
    - cwd: {{ machine.user.home }}/{{ machine.user.name }}/Downloads
    - require:
      - cmd: get_R_pkg

fix_library_permissions:
  cmd.run:
    - name: chown -R {{ machine.user.name }}:admin /Library/Frameworks/R.framework/Resources/library
    - require:
      - cmd: install_R

install_biocmanager:
  cmd.run:
    - name: Rscript -e "install.packages('BiocManager', repos='https://cran.r-project.org'); library(BiocManager); BiocManager::install(ask=FALSE)"
    - runas: {{ machine.user.name }}
    - require:
      - cmd: fix_library_permissions 

{%- for pkg in r.cran %}
install_cran_{{ pkg }}:
  cmd.run:
    - name: Rscript -e "install.packages('{{ pkg }}', repos='https://cran.r-project.org')"
    - runas: {{ machine.user.name }}
    - require:
      - cmd: install_R
{% endfor %}

{%- if build.cycle == 'devel' %}
install_biocmanager_devel:
  cmd.run:
    - name: Rscript -e "library(BiocManager); BiocManager::install(version='devel', ask=FALSE)" 
    - runas: {{ machine.user.name }}
    - require:
      - cmd: install_R
{% endif %}

{%- for pkg in r.bioc %}
install_bioc_{{ pkg }}:
  cmd.run:
    - name: Rscript -e "library(BiocManager); BiocManager::install('{{ pkg }}')"
    - runas: {{ machine.user.name }}
    - require:
      - cmd: install_R
{% endfor %}

check_rtrackerlayer_statically_linked:
  cmd.run:
    - name: otool -L /Library/Frameworks/R.framework/Resources/library/rtracklayer/libs/rtracklayer.so
    - runas: {{ machine.user.name }}
    - require:
      - cmd: install_bioc_rtracklayer

reconfigure_R_to_use_Java:
  cmd.run:
    - name: R CMD javareconf

add_cairo_hack_for_polygon_edge_not_found:
  file.replace:
    - name: /Library/Frameworks/R.framework/Resources/library/grDevices/R/grDevices
    - pattern: {{ 'local({' | regex_escape }}
    - repl: |
        local({
            options(bitmapType="cairo")
    - count: 1
    - require:
      - cmd: install_cran_Cairo

{%- if grains["osarch"]== "arm64" %}
{% set binary_path = "big-sur-arm64/contrib" %}
{% else %}
{% set binary_path = "contrib" %}
{% endif %}

{%- for pkg in r.difficult_pkgs %}
attempt_install_difficult_package_{{ pkg }}:
  cmd.run:
    - name: Rscript -e "install.packages('{{ pkg }}', repos='https://cran.r-project.org')"
    - runas: {{ machine.user.name }}
    - unless:
      - ls /Library/Frameworks/R.framework/Resources/library | egrep {{ pkg }}
    - require:
      - cmd: install_R

attempt_install_previous_version_of_{{ pkg }}:
  cmd.run:
    - name: Rscript -e "if (!('{{ pkg }}' %in% rownames(installed.packages()))) install.packages('{{ pkg }}', repos='https://cran.r-project.org/bin/macosx/{{ binary_path }}/{{ r.previous_version }}')"
    - runas: {{ machine.user.name }}
    - unless:
      - ls /Library/Frameworks/R.framework/Resources/library | egrep {{ pkg }}
    - require:
      - cmd: install_R
{%- endfor %}

symlink_previous_version:
  file.symlink:
    - name: /Library/Frameworks/R.framework/Versions/{{ r.previous_version[2:] }}
    - target: '{{ r.version[2:] }}-{{ subpath }}'
    - cwd: /Library/Frameworks/R.framework/Versions
    - force: True
    - user: {{ machine.user.name }}
    - group: staff

download_minimum_supported_macossdk:
  cmd.run:
    - name: curl -LO https://mac.r-project.org/sdk/MacOSX11.3.sdk.tar.xz
    - cwd: {{ machine.user.home }}/{{ machine.user.name }}/Downloads
    - require:
      - file: symlink_previous_version

untar_macossdk:
  cmd.run:
    - name: tar -xf {{ machine.user.home }}/{{ machine.user.name }}/Downloads/MacOSX11.3.sdk.tar.xz
    - cwd: /Library/Developer/CommandLineTools/SDKs 
    - group: wheel
    - require:
      - cmd: download_minimum_supported_macossdk

symlink_minor_to_major_version:
  file.symlink:
    - name: /Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk
    - target: MacOSX11.3.sdk
    - cwd: /Library/Developer/CommandLineTools/SDKs 
    - group: wheel 
    - require:
      - cmd: untar_macossdk

fix_gfortran_sdk_symlink:
  file.symlink:
    - name: /opt/gfortrant/SDK 
    - target: /Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk
    - cwd: /opt/gfortran 
    - group: admin
    - require:
      - file: symlink_minor_to_major_version

export_minimum_build_in_profile:
  file.append:
    - name: /etc/profile
    - text: |
        export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk
        export MACOSX_DEPLOYMENT_TARGET=11.0
    - require:
      - file: fix_gfortran_sdk_symlink
