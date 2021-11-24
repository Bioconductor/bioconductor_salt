{% set machine = salt["pillar.get"]("machine") %}
{% set build = salt["pillar.get"]("build") %}
{% set r = salt["pillar.get"]("r") %}
{% set tarball = r.download.split("/")[-1] %}
{% set extracted_directory = r.download.split("/")[-1][:-7].split("_")[0] %} 

get_R_tarball:
  cmd.run:
    - name: curl -L {{ r.download }} -o /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ tarball }}
    - creates: /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ r.version }}.tar.gz

fix_permissions_ownership_R_tarball:
  file.managed:
    - name: /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ tarball }}
    - user: biocbuild
    - group: biocbuild

R_tarball_extracted:
  archive.extracted:
    - name: /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/
    - source: /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ tarball }}
    - user: biocbuild
    - group: biocbuild

set_R_SVN_REVISION:
  cmd.run:
    - name: cat /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ extracted_directory }}/SVN-REVISION | awk '{print $2}' | head -n1 > /tmp/R_SVN_REVISION

rename_r_tarball:
  cmd.run:
    - name: mv -n /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ tarball }} /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ r.version }}.r$(cat /tmp/R_SVN_REVISION).tar.gz

rename_extracted_directory:
  cmd.run:
    - name: mv -n /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ extracted_directory }} /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ r.version }}.r$(cat /tmp/R_SVN_REVISION)

# If salt-call is run multiple times
remove_{{ r.version }}_tarball:
  file.absent:
    - name: /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ tarball }}

# If salt-call is run multiple times
remove_{{ r.version }}_directory:
  file.absent:
    - name: /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ extracted_directory }}

remove_R_old:
  file.absent:
    - name: /home/biocbuild/bbs-{{ build.version }}-bioc/R.old

move_R_to_old:
  file.rename:
    - name: /home/biocbuild/bbs-{{ build.version }}-bioc/R.old
    - source: /home/biocbuild/bbs-{{ build.version }}-bioc/R
    - require:
      - file: remove_R_old

make_R_directory:
  file.directory:
    - name: /home/biocbuild/bbs-{{ build.version }}-bioc/R
    - user: biocbuild
    - group: biocbuild
    - makedirs: True
    - replace: False

configure_R:
  cmd.run:
    - name: /home/biocbuild/bbs-{{ build.version }}-bioc/rdownloads/{{ r.version }}.r$(cat /tmp/R_SVN_REVISION)/configure --enable-R-shlib
    - cwd: /home/biocbuild/bbs-{{ build.version }}-bioc/R
    - runas: biocbuild

make_R:
  cmd.run:
    - name: make -j{%- if machine.cores is defined %}{{ machine.cores }}{%- endif %}
    - cwd: /home/biocbuild/bbs-{{ build.version }}-bioc/R
    - runas: biocbuild

run_R-fix-flags.sh:
  cmd.run:
    - name: /home/biocbuild/BBS/utils/R-fix-flags.sh
    - cwd: /home/biocbuild/bbs-{{ build.version }}-bioc/R/etc
    - runas: biocbuild

install_biocmanager:
  cmd.run:
    - name: /home/biocbuild/bbs-{{ build.version }}-bioc/R/bin/Rscript -e "install.packages('BiocManager', repos='https://cran.r-project.org'); library(BiocManager); BiocManager::install(ask=FALSE)"
    - runas: biocbuild

{%- if build.cycle == 'devel' %}
install_biocmanager_devel:
  cmd.run:
    - name: /home/biocbuild/bbs-{{ build.version }}-bioc/R/bin/Rscript -e "library(BiocManager); BiocManager::install(version='devel', ask=FALSE)" 
    - runas: biocbuild
{% endif %}
