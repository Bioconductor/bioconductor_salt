# Needed for ensemblVEP 

brew_install_mysql_client:
  cmd.run:
    - name: brew install mysql-client
    - runas: biocbuild

add_mysql_to_path_in_/etc/profile:
  file.append:
    - name: /etc/profile
    - text: |
        export PATH=$PATH:/usr/local/opt/mysql-client/bin
        export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/mysql-client/lib/pkgconfig
    - require:
      - cmd: brew_install_mysql_client

symlink_mysql_to_libssl:
  file.symlink:
    - name: /usr/local/opt/mysql-client/lib/libssl.dylib
    - target: /usr/local/opt/openssl/lib/libssl.dylib 
    - require:
      - file: add_mysql_to_path_in_/etc/profile

symlink_mysql_to_libcrypto:
  file.symlink:
    - name: /usr/local/opt/mysql-client/lib/libcrypto.dylib
    - target: /usr/local/opt/openssl/lib/libcrypto.dylib 
    - require:
      - file: add_mysql_to_path_in_/etc/profile
