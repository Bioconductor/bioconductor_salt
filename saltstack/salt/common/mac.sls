# Copy salt files into /opt/saltstack
# Place biocbuild ssh key into /opt/salt/common/files
# Place an authorized_keys file with core team member public keys in /opt/salt/common/files

{% set machine = salt["pillar.get"]("machine") %}
{% set build = salt["pillar.get"]("build") %}
{% set repo = salt["pillar.get"]("repo") %}
{% set xquartz = machine.downloads.xquartz.split("/")[-1][:-4] %}
{%- if grains["osarch"] == "arm64" %}
{% set gfortran_download = machine.downloads.arm64.gfortran %}
{% set gfortran = machine.downloads.arm64.gfortran.split("/")[-1] %}
{% else %}
{% set gfortran_download = machine.downloads.intel.gfortran %}
{% set gfortran = machine.downloads.intel.gfortran.split("/")[-1][:-4] %}
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
create_biocbuild:
  cmd.run:
    - name: |
        dscl . -create /Users/biocbuild
        dscl . -create /Users/biocbuild UserShell /bin/bash
        dscl . -create /Users/biocbuild UniqueID "505"
        dscl . -create /Users/biocbuild PrimaryGroupID 20
        dscl . -create /Users/biocbuild NFSHomeDirectory /Users/biocbuild
        dscl . -passwd /Users/biocbuild {{ salt['environ.get']('BIOCBUILD_PASSWORD') }} 
        dscl . -append /Groups/admin GroupMembership biocbuild
        cp -R /System/Library/User\ Template/English.lproj /Users/biocbuild
        chown -R biocbuild:staff /Users/biocbuild
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
      - cmd: create_biocbuild

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
      - cmd: create_biocbuild
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
      - cmd: create_biocbuild
{%- endif %}
{%- endfor %}
{%- endif %}

git_clone_{{ repo.bbs.name }}_to_{{ machine.user.home }}/biocbuild:
  git.cloned:
    - name: {{ repo.bbs.github }}
    - target: {{ machine.user.home }}/biocbuild/{{ repo.bbs.name }}
    - user: biocbuild

download_XQuartz:
  cmd.run:
    - name: curl -LO {{ machine.downloads.xquartz }}
    - cwd: {{ machine.user.home }}/biocbuild/Downloads

install_XQuartz:
  cmd.run:
    - name: |
        hdiutil attach {{ xquartz }}.dmg
        installer -pkg /Volumes/{{ xquartz }}/XQuartz.pkg -target /
        hdiutil detach /Volumes/{{ xquartz }}
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
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
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - runas: biocbuild

{%- if grains["osarch"] == "arm64" %}
install_gfortran:
  cmd.run:
    - name: tar fxz {{ gfortran }} -C /
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - require:
      - cmd: download_gfortran

export_gfortran_path:
  file.append:
    - name: /etc/profile
    - text: |
        export PATH=$PATH:/opt/R/arm64/gfortran/bin
    - require:
      - cmd: install_gfortran
{% else %}
install_gfortran:
  cmd.run:
    - name: |
        hdiutil attach {{ gfortran }}.dmg
        installer -pkg /Volumes/{{ gfortran }}//gfortran.pkg -target /
        hdiutil detach /Volumes/{{ gfortran }}
    - cwd: {{ machine.user.home }}/biocbuild/Downloads 
    - require:
      - cmd: download_gfortran

export_gfortran_path:
  file.append:
    - name: /etc/profile
    - text: |
        export PATH=$PATH:/usr/local/gfortran/bin
    - require:
      - cmd: install_gfortran
{%- endif %}

fix_/usr/local_permissions_for_brewing:
  cmd.run:
    - name: |
        chown -R biocbuild:admin /usr/local/*

brew_packages:
  cmd.run:
    - name: brew install {{ machine.brews }}
    - runas: biocbuild

append_openssl_configurations_to_path:
  file.append:
    - name: /etc/profile
    - text: |
        export PATH=$PATH:/opt/homebrew/Cellar/openssl@3/3.0.5/bin
        export PKG_CONFIG_PATH=$PATH:/opt/homebrew/Cellar/openssl@3/3.0.5/lib/pkgconfig
        export OPENSSL_LIBS="/opt/homebrew/Cellar/openssl@3/3.0.5/lib/libssl.a /opt/homebrew/Cellar/openssl@3/3.0.5/lib/libcrypto.a"
    - require:
      - cmd: brew_packages

pip_install_psutil:
  pip.installed:
    - name: psutil
    - runas: biocbuild

install_pip_pkgs:
  cmd.run:
    - name: python3 -m pip install $(cat {{ machine.user.home }}/biocbuild/{{ repo.bbs.name }}/Ubuntu-files/20.04/pip_*.txt | awk '/^[^#]/ {print $1}')
    - runas: biocbuild

download_mactex:
  cmd.run:
    - name: curl -LO {{ machine.downloads.mactex }}
    - cwd:  {{ machine.user.home }}/biocbuild/Downloads
    - runas: biocbuild

install_mactex:
  cmd.run:
    - name: installer -pkg MacTeX.pkg -target /
    - cwd:  {{ machine.user.home }}/biocbuild/Downloads
    - require:
      - cmd: download_mactex

{%- if grains["osarch"]== "arm64" %}
install_pandoc:
  cmd.run:
    - name: brew install pandoc
    - runas: biocbuild
{% else %}
{% set pandoc = machine.downloads.intel.pandoc.split("/")[-1] %}

download_pandoc:
  cmd.run:
    - name: curl -LO {{ machine.downloads.intel.pandoc }}
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - user: biocbuild

install_pandoc:
  cmd.run:
    - name: installer -pkg {{ pandoc }} -target /
    - cwd: {{ machine.user.home }}/biocbuild/Downloads
    - require:
      - cmd: download_pandoc
{%- endif %}

fix_/usr/local_permissions:
  cmd.run:
    - name: |
        chown -R biocbuild:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive
    - require:
      - cmd: install_mactex
      - cmd: install_pandoc

run_chown-rootadmin:
  cmd.run:
    - name: gcc chown-rootadmin.c -o chown-rootadmin
    - runas: biocbuild
    - cwd: {{ machine.user.home }}/biocbuild/BBS/utils
    - require:
      - cmd: fix_/usr/local_permissions

fix_chown-rootadmin_permissions:
  cmd.run:
    - name: |
        chown root:admin chown-rootadmin
        chmod 4750 chown-rootadmin
    - cwd: {{ machine.user.home }}/biocbuild/BBS/utils
    - require:
      - cmd: run_chown-rootadmin
