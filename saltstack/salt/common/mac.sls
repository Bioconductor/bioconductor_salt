# Copy salt files into /srv/salt
# Place biocbuild ssh key into /srv/salt/common/files
# Place an authorized_keys file with core team member public keys in /srv/salt/common/files

{% set machine = salt["pillar.get"]("machine") %}
{% set build = salt["pillar.get"]("build") %}
{% set repo = salt["pillar.get"]("repo") %}
{% set xquartz = machine.downloads.xquartz.split("/")[-1][:-4] %}
{% set gfortran = machine.downloads.gfortran.split("/")[-1][:-4] %}
{% set pandoc = machine.downloads.pandoc.split("/")[-1] %}

change_hostname:
  cmd.run:
    - name: |
        scutil --set ComputerName {{ machine.name }}
        scutil --set LocalHostName {{ machine.name }}
        scutil --set HostName {{machine.name }}.bioconductor.org

set_dns_servers:
  cmd.run:
    - name: networksetup -setdnsservers 'Ethernet 1' 216.126.35.8 216.24.175.3 8.8.8.8

update:
  cmd.run:
    - name: |
        softwareupdate -l
        softwareupdate -ia --verbose

create_biocbuild:
  cmd.run:
    - name: |
        dscl . -create /Users/biocbuild
        dscl . -create /Users/biocbuild UserShell /bin/bash
        dscl . -create /Users/biocbuild UniqueID "505"
        dscl . -create /Users/biocbuild PrimaryGroupID 20
        dscl . -create /Users/biocbuild NFSHomeDirectory /Users/biocbuild
        dscl . -passwd /Users/biocbuild <password_for_biocbuild>
        dscl . -append /Groups/admin GroupMembership biocbuild
        cp -R /System/Library/User\ Template/English.lproj /Users/biocbuild
        chown -R biocbuild:staff /Users/biocbuild

{% if machine.additional is defined %}
{% set groups = machine.groups + machine.additional.groups %}
{% else %}
{% set groups = machine.groups %}
{% endif %}

{%- for group in groups %}
make_group_{{ group }}:
  group.present:
    - name: {{ group }}
{%- endfor %}

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
    - shell: /usr/bin/bash
    - groups:
    {%- for group in user.groups %}
      - {{ group }}
    {%- endfor %}

{%- if user.key is defined %}
copy_{{ user.name }}_ssh_key:
  file.managed:
    - name: {{ machine.user.home }}/{{ user.name }}/.ssh/{{ user.name }}
    - source: {{ user.key }} 
    - user: {{ user.name }} 
    - group: {{ user.name }}
    - makedirs: True
    - mode: 500
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
{%- endif %}
{%- endfor %}

download_XQuartz:
  file.managed:
    - name: {{ machine.downloads.xquartz }}
    - cwd: {{ machine.user.home }}/Downloads

install_XQuartz:
  cmd.run:
    - name: |
        hdiutil attach {{ xquartz }}.dmg
        installer -pkg /Volumes/{{ xquartz }}/XQuartz.pkg -target /
        hdiutil detach /Volumes/{{ xquartz }}

symlink_x11:
  file.symlink:
    - name: /usr/local/include/X11
    - target: /opt/X11/include/X11
    - user: biocbuild
    - group: biocbuild

{# Run Xvfb as a service #}

create_xvfb_plist:
  file.managed:
    - name: /Library/LaunchDaemons/local.xvfb.plist
    - source: salt://common/files/local.xvfb.plist

create_xvfb.conf:
  file.managed:
    - name: /etc/newsyslog.d/xvfb.conf
    - contents: |
        # logfilename          [owner:group]    mode count size when  flags [/pid_file] [sig_num]
        /var/log/xvfb/xvfb.stderror.log         644  5     5120 *     JN
        /var/log/xvfb/xvfb.stdout.log           644  5     5120 *     JN

simulate_rotation:
  cmd.run:
    - name: newsyslog -nvv

export_global_variable_DISPLAY:
  file.append:
    - name: /etc/profile
    - contents: export DISPLAY=:1.0

load_xvfb:
  cmd.run:
    - name: launchctl load /Library/LaunchDaemons/local.xvfb.plist

download_gfortran:
  file.managed:
    - name: {{ machine.user.home }}/Downloads
    - source: {{ machine.mac.gfortran }}
    - user: biocbuild

install_gfortran:
  cmd.run:
    - name: |
        hdiutil attach {{ gfortran }}.dmg
        installer -pkg /Volumes/{{ gfortran }}/{{ gfortran }}/gfortran.pkg -target /
        hdiutil detach /Volumes/{{ gfortran }}

brew_packages:
  cmd.run:
    - name: brew install {{ machine.brews }}
    - user: biocbuild

append_openssl_configurations_to_path:
  file.append:
    - name: /etc/profile
    - text: |
        PATH=$PATH:/usr/local/opt/openssl@3/bin
        PKG_CONFIG_PATH=$PATH:/usr/local/opt/openssl@3/bin
        export OPENSSL_LIBS="/usr/local/opt/openssl@3/lib/libssl.a /usr/local/opt/openssl@3/lib/libcrypto.a"

pip_install_psutil:
  pip.installed:
    - name: psutil
    - bin_env: /usr/bin/pip3
    - user: biocbuild

install_pip_pkgs:
  cmd.run:
    - name: python3 -m pip install $(cat {{ machine.user.home }}/biocbuild/{{ repo.bbs.name }}/Ubuntu-files/20.04/pip_*.txt | awk '/^[^#]/ {print $1}')

download_mactex:
  file.managed:
    - name:  {{ machine.user.home }}/Downloads
    - source: {{ machine.downloads.mactex }}
    - user: biocbuild

install_mactex:
  cmd.run:
    name: installer -pkg MacTex.pkg -target /

download_pandoc:
  file.managed:
    - name: {{ machine.user.home }}/Downloads
    - source: {{ machine.downloads.pandoc }}
    - user: biocbuild

install_pandoc:
  cmd.run:
    - name: installer -pkg {{ pandoc }} -target /

fix_/usr/local_permissions:
  cmd.run:
    - name: |
        chown -R biocbuild:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive

{%- for type in build.types %}
make_{{ build.version }}_{{ type }}_directory:
  file.directory:
    - name: {{ machine.user.home }}/biocbuild/bbs-{{ build.version }}-{{ type }}/log
    - user: biocbuild
    - group: biocbuild
    - makedirs: True
    - replace: False
{%- endfor %}

make_{{ build.version }}_bioc_rdownloads:
  file.directory:
    - name: {{ machine.user.home }}/biocbuild/bbs-{{ build.version }}-bioc/rdownloads
    - user: biocbuild
    - group: biocbuild
    - makedirs: True
    - replace: False

{%- for job in build.cron.jobs %}
add_{{ job.name }}_crontab:
  cron.present:
    - name: {{ job.command}}
    - user: biocbuild
    - minute: "{{ job.minute }}"
    - hour: "{{ job.hour }}"
    - daymonth: "{{ job.daymonth }}"
    - month: "{{ job.month }}"
    - dayweek: "{{ job.dayweek }}"
    - comment: {{ job.comment }}
    - commented: {{ job.commented }}
{%- endfor %}
