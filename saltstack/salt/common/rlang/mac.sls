{% set machine = salt["pillar.get"]("machine") %}
{% set r = salt["pillar.get"]("r") %}
{% set downloaded_file  = r.download.split("/")[-1] %}

remove_old_r:
  file.absent:
    - name: /Library/Frameworks/R.framework

get_R_pkg:
  file.managed:
    - name: {{ machine.user.home }}/biocbuild/Download/{{ r.download }}

install_R:
  cmd.run:
    - name: installer -pkg {{ downloaded_file }} -target /
    - cwd: {{ machine.user.home }}/biocbuild/Download
    - runas: biocbuild

install_biocmanager:
  cmd.run:
    - name: Rscript -e "install.packages('BiocManager', repos='https://cran.r-project.org'); library(BiocManager); BiocManager::install(ask=FALSE)"
    - runas: biocbuild

{%- for package in ['rgl', 'Rcpp', 'minqa', 'Cairo', 'devtools'] %}
install_{{ package }}:
  cmd.run:
    - name: Rscript -e "install.packages({{ package }}, repos='https://cran.r-project.org')"
    - runas: biocbuild
{%- endfor %}

{%- if build.cycle == 'devel' %}
install_biocmanager_devel:
  cmd.run:
    - name: Rscript -e "library(BiocManager); BiocManager::install(version='devel', ask=FALSE)" 
    - runas: biocbuild
{% endif %}

{%- for package in ['BiocCheck', 'BiocStyle', 'rtracklayer', 'VariantAnnotation', 'rhdf5'] %}
install_bioccheck:
  cmd.run:
    - name: Rscript -e "library(BiocManager); BiocManager::install({{ package }})" 
    - runas: biocbuild
{%- endfor %}

check_rtrackerlayer_statically_linked:
  cmd.run:
    - name: otool -L /Library/Frameworks/R.framework/Resources/library/rtracklayer/libs/rtracklayer.so
    - runas: biocbuild

configure_R_to_use_Java:
  cmd.run:
    - name: R CMD javareconf

add_cairo_hack: {# for polygon edge not found #}
  file.replace:
    - name: /Library/Frameworks/R.framework/Resources/library/grDevices/R/grDevices
    - pattern: local\(\{
    - repl: |
        local({
            options(bitmapType="cairo")

{%- for package in r.difficult-pkgs %}
install_{{ package }}:
  cmd.run:
    - name: Rscript -e "install.packages({{ package }}, repos='https://cran.r-project.org')"
    - runas: biocbuild
{%- endfor %}

{%- for package in r.difficult-pkgs %}
install_{{ package }}:
  cmd.run:
    - name: Rscript -e "if (!{{ package }} %in% rownames(installed.packages())
      install.packages({{ package }},
      repos='https://cran.r-project.org/bin/macosx/contrib/{{ r.previous_version }}')"
    - runas: biocbuild
{%- endfor %}

symlink_previous_version:
  file.symlink:
    - name: /Library/Frameworks/R.framework/Versions/{{ r.version }}
    - target: {{ r.previous_version }}
    - force: True
    - user: biocbuild
    - group: biocbuild
