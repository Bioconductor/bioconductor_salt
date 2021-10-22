install_cpanminus:
  pkg.installed:
    - name: cpanminus

install_perl_modules_for_ensemblVEP_MMAPPR2:
  cmd.run:
    - name: |
        cpanm -vn Archive::Zip
        cpanm -vn File::Copy::Recursive
        cpanm -vn DBI
        cpanm -vn DBD::mysql

install_perl_modules_for_MMAPPR2:
  cmd.run:
    - name: |
        cpanm -vnf XML::DOM::XPath
        cpanm -vn IO::String
        cpanm -vn Bio::SeqFeature::Lite

install_libhts-dev:
  pkg.installed:
    - name: libhts-dev

create_symlinks_for_libhts.so:
  file.symlink:
    - name: /usr/lib/libhts.so
    - target: x86_64-linux-gnu/libhts.so

create_symlinks_for_libhts.a:
  file.symlink:
    - name: /usr/lib/libhts.a
    - target: x86_64-linux-gnu/libhts.a

install_perl_module_tabix:
  cmd.run:
    - name: cpanm -vn Bio::DB::HTS::Tabix

clone_ensemblvep:
  git.cloned:
    - name: https://github.com/Ensembl/ensembl-vep.git
    - target: /usr/local/ensembl-vep

remove_bio_directory:
  file.absent:
    - name: /usr/local/ensembl-vep/Bio

perl_install_ensemblvep:
  cmd.run:
    - name: perl INSTALL.pl --NO_HTSLIB --AUTO a
    - cwd: /usr/local/ensembl-vep

append_ensemblvep_to_path:
  file.append:
    - name: /etc/profile
    - text: export PATH=$PATH:/usr/local/ensembl-vep
