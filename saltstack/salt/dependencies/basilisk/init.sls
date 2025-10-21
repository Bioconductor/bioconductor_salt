set_BASILISK_EXTERNAL_DIR:
  file.append:
    - name: /etc/profile
    - text: |
        export BASILISK_EXTERNAL_DIR="/var/cache/basilisk"
