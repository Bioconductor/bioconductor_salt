# Needed for BioC ensemblVEP, BioC MMAPPR2

{% set machine = salt["pillar.get"]("machine") %}

{%- if machine.r_path is defined %}
{% set r_path = machine.r_path %}
{% else %}
{% set r_path = '' %}
{%- endif %}

install_cpanminus:
  pkg.installed:
    - name: cpanminus

install_perl_modules_for_ensemblVEP_MMAPPR2:
  cmd.run:
    - name: |
        . /etc/profile
        cpanm -vn Archive::Zip
        cpanm -vn File::Copy::Recursive
        cpanm -vn DBI
        cpanm -vn DBD::mysql
    - require:
      - pkg: install_cpanminus

install_perl_modules_for_MMAPPR2:
  cmd.run:
    - name: |
        cpanm -vnf XML::DOM::XPath
        cpanm -vn IO::String
        cpanm -vn Bio::SeqFeature::Lite

{%- if grains['os'] == 'Ubuntu' %}
install_libhts-dev:
  pkg.installed:
    - name: libhts-dev
    - require:
      - cmd: install_perl_modules_for_ensemblVEP_MMAPPR2

create_symlinks_for_libhts.so:
  file.symlink:
    - name: /usr/lib/libhts.so
    - target: x86_64-linux-gnu/libhts.so
    - require:
      - cmd: install_perl_modules_for_ensemblVEP_MMAPPR2

create_symlinks_for_libhts.a:
  file.symlink:
    - name: /usr/lib/libhts.a
    - target: x86_64-linux-gnu/libhts.a
    - require:
      - cmd: install_perl_modules_for_ensemblVEP_MMAPPR2
{% elif grains['os'] == 'MacOS' %}
brew_install_htslib:
  cmd.run:
    - name: brew install htslib
    - runas: {{ machine.user.name }}
{%- endif %}

install_perl_module_tabix:
  cmd.run:
    - name: cpanm -vn Bio::DB::HTS::Tabix

clone_ensemblvep:
  git.cloned:
    - name: https://github.com/Ensembl/ensembl-vep.git
    - target: /usr/local/ensembl-vep
    - require:
      - cmd: install_perl_module_tabix

{%- if grains['os'] == 'Ubuntu' %}
remove_bio_directory:
  file.absent:
    - name: /usr/local/ensembl-vep/Bio
    - require:
      - git: clone_ensemblvep
{% elif grains['os'] == 'MacOS' %}
change_ensembl-vep_permissions:
  cmd.run:
    - name: chown -R {{ machine.user.name }}:admin /usr/local/ensembl-vep
    - require:
      - git: clone_ensemblvep
{%- endif %}

perl_install_ensemblvep:
  cmd.run:
    - name: perl INSTALL.pl --NO_HTSLIB --AUTO a
    - cwd: /usr/local/ensembl-vep

append_ensemblvep_to_path:
  file.append:
    - name: /etc/profile
    - text: export PATH=$PATH:/usr/local/ensembl-vep
    - require:
      - cmd: perl_install_ensemblvep

{%- for pkg in ['ensemblVEP', 'MMAPPR2'] %}
test_R_CMD_build_{{ pkg }}:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/{{ pkg }}
        {{ r_path }}R CMD build {{ pkg }} 
        ls {{ pkg }}*.tar.gz | {{ r_path }}R CMD check --no-vignettes 
    - cwd: /tmp
    - runas: {{ machine.user.name }}
    - require:
      - file: append_ensemblvep_to_path
{%- endfor %}
