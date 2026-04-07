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
    - name: Rscript -e "install.packages('BiocManager', repos='{{ r.cran_mirror }}'); library(BiocManager); BiocManager::install(ask=FALSE)"
    - runas: {{ machine.user.name }}
    - require:
      - cmd: fix_library_permissions 

{%- for pkg in r.cran %}
install_cran_{{ pkg }}:
  cmd.run:
    - name: Rscript -e "install.packages('{{ pkg }}', repos='{{ r.cran_mirror }}')"
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

{%- if grains["osarch"] == "arm64" %}
{% set binary_path = "sonoma-arm64/contrib" %}
{% else %}
{% set binary_path = "contrib" %}
{% endif %}

{# Run twice as additional packages may be available after the second installation attempt #}
{% for i in range(1, 3) %}
attempt_install_difficult_packages_{{ i }}:
  cmd.run:
    - name: |
        Rscript -e "options(timeout=180); install.packages(setdiff(c('{{ r.difficult_pkgs|join("','") }}'), rownames(installed.packages())), repos='{{ r.cran_mirror }}')"
        Rscript -e "options(timeout=180); install.packages(setdiff(c('{{ r.difficult_pkgs|join("','") }}'), rownames(installed.packages())), contriburl='{{ r.cran_mirror }}/bin/macosx/{{ binary_path }}/{{ r.previous_version }}')"
    - runas: {{ machine.user.name }}
    - require:
      - cmd: install_R
{% endfor %}

symlink_previous_version:
  file.symlink:
    - name: /Library/Frameworks/R.framework/Versions/{{ r.previous_version[2:] }}
    - target: '{{ r.version[2:] }}'
    - cwd: /Library/Frameworks/R.framework/Versions
    - force: True
    - user: root
    - group: staff

{# SDKs must be downloaded from https://developer.apple.com and placed in the
   user's Downloads directory. If found, salt will untar, install, and symlink.
   If not found, or if not on macOS, these steps are skipped gracefully. #}

untar_macossdk:
  cmd.run:
    - name: tar -xf {{ machine.user.home }}/{{ machine.user.name }}/Downloads/MacOSX26.2.sdk.tar.xz
    - cwd: /Library/Developer/CommandLineTools/SDKs
    - user: root
    - group: wheel
    - onlyif:
      - test -f {{ machine.user.home }}/{{ machine.user.name }}/Downloads/MacOSX26.2.sdk.tar.xz
    - require:
      - file: symlink_previous_version

warn_sdk_missing:
  test.show_notification:
    - text: "MacOSX26.2.sdk.tar.xz not found in Downloads — skipping SDK install"
    - onfail:
      - cmd: untar_macossdk

symlink_minor_to_major_version:
  file.symlink:
    - name: /Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk
    - target: MacOSX26.2.sdk
    - cwd: /Library/Developer/CommandLineTools/SDKs
    - user: root
    - group: wheel
    - onlyif:
      - test -d /Library/Developer/CommandLineTools/SDKs/MacOSX26.2.sdk
    - require:
      - cmd: untar_macossdk

fix_gfortran_sdk_symlink:
  file.symlink:
    - name: /opt/gfortran/SDK
    - target: /Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk
    - cwd: /opt/gfortran
    - user: root
    - group: admin
    - require:
      - file: symlink_minor_to_major_version

export_minimum_build_in_profile:
  file.append:
    - name: /etc/profile
    - text: |
        export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.sdk
        export MACOSX_DEPLOYMENT_TARGET=14.0
    - require:
      - file: fix_gfortran_sdk_symlink
