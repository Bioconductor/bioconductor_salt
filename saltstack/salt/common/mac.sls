# Copy salt files into /opt/saltstack
# Place biocbuild ssh key into /opt/salt/common/files
# Place an authorized_keys file with core team member public keys in /opt/salt/common/files

{% set machine = salt["pillar.get"]("machine") %}
{% set build = salt["pillar.get"]("build") %}
{% set repo = salt["pillar.get"]("repo") %}
{% set xquartz = machine.downloads.xquartz.split("/")[-1] %}
{% set openssl = machine.downloads.openssl.split("/")[-1] %}
{% set gfortran_download = machine.downloads.gfortran %}
{% set gfortran = machine.downloads.gfortran.split("/")[-1] %}
{%- if grains["osarch"] == "arm64" %}
{% set subpath = "arm64" %}
{%- else %}
{% set subpath = "x86_64" %}
{%- endif %}


change_hostname:
  cmd.run:
    - name: |
        scutil --set ComputerName {{ machine.name }}
        scutil --set LocalHostName {{ machine.name }}
        scutil --set HostName {{machine.name }}.bioconductor.org

set_dns_servers:
  cmd.run:
    - name: networksetup -setdnsservers "$(networksetup -listallnetworkservices | awk 'NR==2')" 216.126.35.8 216.24.175.3 8.8.8.8
    - require:
      - cmd: change_hostname

update:
  cmd.run:
    - name: |
        softwareupdate -l
        softwareupdate -ia --verbose
    - require:
      - cmd: set_dns_servers

{%- if machine.create_users %}
create_{{ machine.user.name }}:
  cmd.run:
    - name: |
        dscl . -create /Users/{{ machine.user.name }}
        dscl . -create /Users/{{ machine.user.name }} UserShell /bin/bash
        dscl . -create /Users/{{ machine.user.name }} UniqueID "505"
        dscl . -create /Users/{{ machine.user.name }} PrimaryGroupID 20
        dscl . -create /Users/{{ machine.user.name }} NFSHomeDirectory /Users/{{ machine.user.name }}
        dscl . -passwd /Users/{{ machine.user.name }} {{ salt['environ.get']('BIOCBUILD_PASSWORD') }}
        dscl . -append /Groups/admin GroupMembership {{ machine.user.name }}
        cp -R /System/Library/User\ Template/English.lproj /Users/{{ machine.user.name }}
        chown -R {{ machine.user.name }}:staff /Users/{{ machine.user.name }}
    - unless:
      - dscl . list /Users | egrep {{ user.name }}
    - require:
      - cmd: update

{% if machine.additional is defined %}
{% set users = machine.users + machine.additional.users %}
{% else %}
{% set users = machine.users %}
{% endif %}

{%- for user in users %}
make_user_{{ user.name }}:
  user.present:
    - name: {{ user.name }}
    - password: {{ user.password }}
    - home: {{ machine.user.home }}/{{ user.name }}
    - shell: /bin/bash
    - groups:
      - staff
      - admin
    - require:
      - cmd: create_{{ machine.user.name }}

{%- if user.key is defined %}
copy_{{ user.name }}_ssh_key:
  file.managed:
    - name: {{ machine.user.home }}/{{ user.name }}/.ssh/{{ user.name }}
    - source: {{ user.key }}
    - user: {{ user.name }}
    - group: staff
    - makedirs: True
    - mode: 500
    - require:
      - cmd: create_{{ machine.user.name }}
{%- endif %}

{%- if user.authorized_key is defined %}
copy_{{ user.name }}_authorized_keys:
  ssh_auth.manage:
    - user: {{ user.name }}
    - enc: ssh-rsa
    - ssh_keys:
    {%- for authorized_key in user.authorized_keys %}
      - {{ authorized_key }}
    {%- endfor %}
    - require:
      - cmd: create_{{ machine.user.name }}
{%- endif %}
{%- endfor %}
{%- endif %}

git_clone_{{ repo.bbs.name }}_to_{{ machine.user.home }}/{{ machine.user.name }}:
  git.cloned:
    - name: {{ repo.bbs.github }}
    - target: {{ machine.user.home }}/{{ machine.user.name }}/{{ repo.bbs.name }}
    - user: {{ machine.user.name }}

download_XQuartz:
  cmd.run:
    - name: curl -LO {{ machine.downloads.xquartz }}
    - cwd: {{ machine.user.home }}/{{ machine.user.name }}/Downloads

install_XQuartz:
  cmd.run:
    - name: |
        installer -pkg {{ xquartz }} -target /
    - cwd: {{ machine.user.home }}/{{ machine.user.name }}/Downloads
    - require:
      - cmd: download_XQuartz

symlink_x11:
  cmd.run:
    - name: ln -s /opt/X11/include/X11 X11
    - cwd: /usr/local/include
    - require:
      - cmd: install_XQuartz

{# Run Xvfb as a service #}

create_xvfb_plist:
  file.managed:
    - name: /Library/LaunchDaemons/local.xvfb.plist
    - contents: |
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
          <dict>
            <key>KeepAlive</key>
              <true/>
            <key>Label</key>
              <string>local.xvfb</string>
            <key>ProgramArguments</key>
              <array>
                <string>/opt/X11/bin/Xvfb</string>
                <string>:1</string>
                <string>-screen</string>
                <string>0</string>
                <string>800x600x16</string>
              </array>
            <key>RunAtLoad</key>
              <true/>
            <key>ServiceDescription</key>
              <string>Xvfb Virtual X Server</string>
            <key>StandardOutPath</key>
              <string>/var/log/xvfb/xvfb.stdout.log</string>
            <key>StandardErrorPath</key>
              <string>/var/log/xvfb/xvfb.stderror.log</string>
          </dict>
        </plist>

create_xvfb.conf:
  file.managed:
    - name: /etc/newsyslog.d/xvfb.conf
    - contents: |
        # logfilename          [owner:group]    mode count size when  flags [/pid_file] [sig_num]
        /var/log/xvfb/xvfb.stderror.log         644  5     5120 *     JN
        /var/log/xvfb/xvfb.stdout.log           644  5     5120 *     JN
    - require:
      - file: create_xvfb_plist

simulate_rotation:
  cmd.run:
    - name: newsyslog -nvv
    - require:
      - file: create_xvfb.conf

export_global_variable_DISPLAY:
  file.append:
    - name: /etc/profile
    - text: export DISPLAY=:1.0
    - require:
      - file: create_xvfb.conf

load_xvfb:
  cmd.run:
    - name: launchctl load /Library/LaunchDaemons/local.xvfb.plist
    - require:
      - file: export_global_variable_DISPLAY

download_gfortran:
  cmd.run:
    - name: curl -LO {{ gfortran_download }}
    - cwd: {{ machine.user.home }}/{{ machine.user.name }}/Downloads
    - runas: {{ machine.user.name }}

install_gfortran:
  cmd.run:
    - name: tar -xf {{ machine.user.home }}/{{ machine.user.name }}/Downloads/{{ gfortran }} -C /
    - require:
      - cmd: download_gfortran

export_gfortran_path:
  file.append:
    - name: /etc/profile
    - text: |
        export PATH=$PATH:/opt/gfortran/bin
    - require:
      - cmd: install_gfortran

symlink_gfortran_sdk:
  cmd.run:
    - name: ln -sfn $(xcrun --show-sdk-path) /opt/gfortran/SDK
    - require:
      - file: export_gfortran_path

fix_/usr/local_permissions_for_brewing:
  cmd.run:
    - name: |
        chown -R {{ machine.user.name }}:admin /usr/local/*

brew_packages:
  cmd.run:
    - name: brew install {{ machine.brews }}
    - runas: {{ machine.user.name }}

{%- for binary for machine.binaries %}
install_{{ binary }}:
  cmd.run:
    - name: |
        sudo Rscript -e "source('https://mac.R-project.org/bin/install.R'); install.libs('{{ binary }}')"
{%- endfor %}

append_openssl_configurations_to_path:
  file.append:
    - name: /etc/profile
    - text: |
        export PATH=$PATH:/opt/R/{{ subpath }}/bin
        export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/opt/R/{{ subpath }}/lib/pkgconfig
        export OPENSSL_LIBS="/opt/R/{{ subpath }}/lib/libssl.a /opt/R/{{ subpath }}/lib/libcrypto.a"
    - require:
      - cmd: install_openssl

install_pip_pkgs:
  cmd.run:
    - name: python3 -m pip install $(cat {{ machine.user.home }}/{{ machine.user.name }}/{{ repo.bbs.name }}/Ubuntu-files/20.04/pip_*.txt | awk '/^[^#]/ {print $1}')
    - runas: {{ machine.user.name }}

download_mactex:
  cmd.run:
    - name: curl -LO {{ machine.downloads.mactex }}
    - cwd:  {{ machine.user.home }}/{{ machine.user.name }}/Downloads
    - runas: {{ machine.user.name }}

install_mactex:
  cmd.run:
    - name: installer -pkg MacTeX.pkg -target /
    - cwd:  {{ machine.user.home }}/{{ machine.user.name }}/Downloads
    - require:
      - cmd: download_mactex

{%- if grains["osarch"]== "arm64" %}
install_pandoc:
  cmd.run:
    - name: brew install pandoc
    - runas: {{ machine.user.name }}
{% else %}
{% set pandoc = machine.downloads.intel.pandoc.split("/")[-1] %}

download_pandoc:
  cmd.run:
    - name: curl -LO {{ machine.downloads.intel.pandoc }}
    - cwd: {{ machine.user.home }}/{{ machine.user.name }}/Downloads
    - user: {{ machine.user.name }}

install_pandoc:
  cmd.run:
    - name: installer -pkg {{ pandoc }} -target /
    - cwd: {{ machine.user.home }}/{{ machine.user.name }}/Downloads
    - require:
      - cmd: download_pandoc
{%- endif %}

fix_/usr/local_permissions:
  cmd.run:
    - name: |
        chown -R {{ machine.user.name }}:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive
    - require:
      - cmd: install_mactex
      - cmd: install_pandoc

run_chown-rootadmin:
  cmd.run:
    - name: gcc chown-rootadmin.c -o chown-rootadmin
    - runas: {{ machine.user.name }}
    - cwd: {{ machine.user.home }}/{{ machine.user.name }}/BBS/utils
    - require:
      - cmd: fix_/usr/local_permissions

fix_chown-rootadmin_permissions:
  cmd.run:
    - name: |
        chown root:admin chown-rootadmin
        chmod 4750 chown-rootadmin
    - cwd: {{ machine.user.home }}/{{ machine.user.name }}/BBS/utils
    - require:
      - cmd: run_chown-rootadmin
