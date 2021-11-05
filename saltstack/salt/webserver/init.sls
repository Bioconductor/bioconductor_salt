install_apache:
  pkg.installed:
    - name: apache2

configure_apache:
  apache.configfile:
    - name: /etc/apache2/sites-available/000-default.conf
    - config:
      - VirtualHost:
          this: '*:80'
          ErrorLog: /var/log/apache2/error.log
          CustomLog: /var/log/apache2/access.log combined
          DocumentRoot: /home/biocbuild/public_html
          Directory:
            this: /home/biocbuild/public_html/
            Options:
              - Indexes FollowSymLinks
            AllowOverride: None
            Require: all granted

enable_site:
  apache_site.enabled:
    - name: 000-default

restart_apache2:
  cmd.run:
    - name: service apache2 restart
