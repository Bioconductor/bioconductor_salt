{% set build = salt["pillar.get"]("build") %}
{% set machine = salt["pillar.get"]("machine") %}
{% set r = salt["pillar.get"]("r") %}
{% set downloaded_file  = r.download.split("/")[-1] %}

remove_old_r:
  file.absent:
    - name: /Library/Frameworks/R.framework

get_R_pkg:
  cmd.run:
    - name: curl -O {{ r.download }}
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - require:
      - file: remove_old_r

install_R:
  cmd.run:
    - name: installer -pkg {{ downloaded_file }} -target /
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - require:
      - cmd: get_R_pkg

fix_library_permissions:
  cmd.run:
    - name: chown -R biocbuild:admin /Library/Frameworks/R.framework/Resources/library
    - require:
      - cmd: install_R

install_biocmanager:
  cmd.run:
    - name: Rscript -e "install.packages('BiocManager', repos='https://cran.r-project.org'); library(BiocManager); BiocManager::install(ask=FALSE)"
    - runas: biocbuild
    - require:
      - cmd: fix_library_permissions 

{%- for pkg in r.cran %}
install_cran_{{ pkg }}:
  cmd.run:
    - name: Rscript -e "install.packages('{{ pkg }}', repos='https://cran.r-project.org')"
    - runas: biocbuild
    - require:
      - cmd: install_R
{% endfor %}

{%- if build.cycle == 'devel' %}
install_biocmanager_devel:
  cmd.run:
    - name: Rscript -e "library(BiocManager); BiocManager::install(version='devel', ask=FALSE)" 
    - runas: biocbuild
    - require:
      - cmd: install_R
{% endif %}

{%- for pkg in r.bioc %}
install_bioc_{{ pkg }}:
  cmd.run:
    - name: Rscript -e "library(BiocManager); BiocManager::install('{{ pkg }}')"
    - runas: biocbuild
    - require:
      - cmd: install_R
{% endfor %}

check_rtrackerlayer_statically_linked:
  cmd.run:
    - name: otool -L /Library/Frameworks/R.framework/Resources/library/rtracklayer/libs/rtracklayer.so
    - runas: biocbuild
    - require:
      - cmd: install_bioc_rtracklayer

configure_R_to_use_Java:
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

{%- for pkg in r.difficult_pkgs %}
attempt_install_difficult_package_{{ pkg }}:
  cmd.run:
    - name: Rscript -e "install.packages('{{ pkg }}', repos='https://cran.r-project.org')"
    - runas: biocbuild
    - unless:
      - ls /Library/Frameworks/R.framework/Resources/library | egrep {{ pkg }}
    - require:
      - cmd: install_R

attempt_install_previous_version_of_{{ pkg }}:
  cmd.run:
    - name: Rscript -e "if (!('{{ pkg }}' %in% rownames(installed.packages()))) install.packages('{{ pkg }}', repos='https://cran.r-project.org/bin/macosx/contrib/{{ r.previous_version }}')"
    - runas: biocbuild
    - unless:
      - ls /Library/Frameworks/R.framework/Resources/library | egrep {{ pkg }}
    - require:
      - cmd: install_R
{%- endfor %}

symlink_previous_version:
  file.symlink:
    - name: /Library/Frameworks/R.framework/Versions/{{ r.previous_version[2:] }}
    - target: '{{ r.version[2:] }}'
    - cwd: /Library/Frameworks/R.framework/Versions
    - force: True
    - user: biocbuild
    - group: staff
