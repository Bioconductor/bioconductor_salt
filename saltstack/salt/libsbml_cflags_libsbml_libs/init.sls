set_LIBSBML_CFLAGS_and_LIBSBML_LIBS:
  file.append:
    - name: /etc/profile
    - text: |
        export LIBSBML_CFLAGS="-I/usr/include"
        export LIBSBML_LIBS="-lsbml"
