{% set machine = salt["pillar.get"]("machine") %}
{% set build = salt["pillar.get"]("build") %}
{% set r = salt["pillar.get"]("r") %}
{% set tarball = r.download.split("/")[-1] %}
{% set extracted_directory = r.download.split("/")[-1][:-7].split("_")[0] %}
{% set bbs_bioc = machine.user.home ~ "/" ~ machine.user.name ~ "/bbs-" ~ build.version ~ "-bioc" %}

get_R_tarball:
  cmd.run:
    - name: curl -L {{ r.download }} -o {{ bbs_bioc }}/rdownloads/{{ tarball }}
    - creates: {{ bbs_bioc }}/rdownloads/{{ r.version }}.tar.gz

fix_permissions_ownership_R_tarball:
  file.managed:
    - name: {{ bbs_bioc }}/rdownloads/{{ tarball }}
    - user: {{ machine.user.name }}
    - group: {{ machine.user.name }}

R_tarball_extracted:
  archive.extracted:
    - name: {{ bbs_bioc }}/rdownloads/
    - source: {{ bbs_bioc }}/rdownloads/{{ tarball }}
    - user: {{ machine.user.name }}
    - group: {{ machine.user.name }}

set_R_SVN_REVISION:
  cmd.run:
    - name: cat {{ bbs_bioc }}/rdownloads/{{ extracted_directory }}/SVN-REVISION | awk '{print $2}' | head -n1 > /tmp/R_SVN_REVISION

rename_r_tarball:
  cmd.run:
    - name: mv -n {{ bbs_bioc }}/rdownloads/{{ tarball }} {{ bbs_bioc }}/rdownloads/{{ r.version }}.r$(cat /tmp/R_SVN_REVISION).tar.gz

rename_extracted_directory:
  cmd.run:
    - name: mv -n {{ bbs_bioc }}/rdownloads/{{ extracted_directory }} {{ bbs_bioc }}/rdownloads/{{ r.version }}.r$(cat /tmp/R_SVN_REVISION)

# If salt-call is run multiple times
remove_{{ r.version }}_tarball:
  file.absent:
    - name: {{ bbs_bioc }}/rdownloads/{{ tarball }}

# If salt-call is run multiple times
remove_{{ r.version }}_directory:
  file.absent:
    - name: {{ bbs_bioc }}/rdownloads/{{ extracted_directory }}

remove_R_old:
  file.absent:
    - name: {{ bbs_bioc }}/R.old

move_R_to_old:
  file.rename:
    - name: {{ bbs_bioc }}/R.old
    - source: {{ bbs_bioc }}/R
    - require:
      - file: remove_R_old

make_R_directory:
  file.directory:
    - name: {{ bbs_bioc }}/R
    - user: {{ machine.user.name }}
    - group: {{ machine.user.name }}
    - makedirs: True
    - replace: False

configure_R:
  cmd.run:
    - name: {{ bbs--bioc }}/rdownloads/{{ r.version }}.r$(cat /tmp/R_SVN_REVISION)/configure --enable-R-shlib
    - cwd: {{ bbs_bioc }}/R
    - runas: {{ machine.user.name }}

make_R:
  cmd.run:
    - name: make -j{%- if machine.cores is defined %}{{ machine.cores }}{%- endif %}
    - cwd: {{ bbs_bioc }}/R
    - runas: {{ machine.user.name }}

make_site-library:
  file.directory:
    - name: {{ bbs_bioc }}/R/site-library
    - user: {{ machine.user.name }}
    - group: {{ machine.user.name }}
    - makedirs: True
    - replace: True
    - require:
      - cmd: make_R

run_R-fix-flags.sh:
  cmd.run:
    - name: {{ machine.user.home }}/{{ machine.user.name }}/BBS/utils/R-fix-flags.sh
    - cwd: {{ bbs_bioc }}/R/etc
    - runas: {{ machine.user.name }}

install_biocmanager:
  cmd.run:
    - name: {{ bbs_bioc }}/R/bin/Rscript -e "install.packages('BiocManager', repos='https://cran.r-project.org'); library(BiocManager); BiocManager::install(ask=FALSE)"
    - runas: {{ machine.user.name }}

{%- if build.cycle == 'devel' %}
install_biocmanager_devel:
  cmd.run:
    - name: {{ bbs_bioc }}/R/bin/Rscript -e "library(BiocManager); BiocManager::install(version='devel', ask=FALSE)"
    - runas: {{ machine.user.name }}
{% endif %}

install_BiocCheck:
  cmd.run:
    - name: {{ bbs_bioc }}/R/bin/Rscript -e "library(BiocManager); BiocManager::install('BiocCheck')"
    - runas: {{ machine.user.name }}

install_Rcpp_minqa_rJava:
  cmd.run:
    - name: {{ bbs_bioc }}/R/bin/Rscript -e "library(BiocManager); BiocManager::install(c('Rcpp', 'minqa', 'rJava'))"
    - runas: {{ machine.user.name }}

install_devtools_BiocStyle_rtracklayer_VariantAnnotation_rhdf5:
  cmd.run:
    - name: {{ bbs_bioc }}/R/bin/Rscript -e "library(BiocManager); BiocManager::install(c('devtools', 'BiocStyle', 'rtracklayer', 'VariantAnnotation', 'rhdf5'))"
    - runas: {{ machine.user.name }}
