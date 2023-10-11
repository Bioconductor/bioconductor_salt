# Copy salt files into /srv/salt
# Place biocbuild ssh key into /srv/salt/common/files
# Place an authorized_keys file with core team member public keys in /srv/salt/common/files

{% set machine = salt["pillar.get"]("machine") %}
{% set build = salt["pillar.get"]("build") %}
{% set repo = salt["pillar.get"]("repo") %}

change_hostname:
  cmd.run:
    - name: echo {{ machine.name }} > /etc/hostname

change_host:
  host.present:
    - ip: {{ machine.ip }}
    - names:
      - {{ machine.name }}
    - clean: True

{% if machine.create_users %}
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
    - shell: {{ machine.user.shell }}
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
{%- endif %}

git_clone_{{ repo.bbs.name }}_to_{{ machine.user.home }}/{{ machine.user.name }}:
  git.cloned:
    - name: {{ repo.bbs.github }}
    - target: {{ machine.user.home }}/{{ machine.user.name }}/{{ repo.bbs.name }}
    - user: {{ machine.user.name }}

install_apt_pkgs:
  cmd.run:
    - name: apt-get -y install $(cat /home/{{ machine.user.name }}/{{ repo.bbs.name }}/{{ grains["os"] }}-files/{{ grains["osrelease"] }}/apt_*.txt | awk '/^[^#]/ {print $1}')

update_pip:
  cmd.run:
    - name: pip install --upgrade pip 

install_pip_pkgs:
  cmd.run:
    - name: python3 -m pip install $(cat /home/{{ machine.user.name }}/{{ repo.bbs.name }}/{{ grains["os"] }}-files/{{ grains["osrelease"] }}/pip_*.txt | awk '/^[^#]/ {print $1}')

check_locale:
  locale.present:
    - name: en_US.UTF-8

change_date_to_24_hours:
  cmd.run:
    - name: "locale-gen 'en_GB'; update-locale LC_TIME='en_GB'"

change_time_to_edt:
  cmd.run:
    - name: timedatectl set-timezone America/New_York

# Set up Xvfb
install_xvfb:
  pkg.installed:
    - name: xvfb

create_xfb_init:
  file.managed:
    - name: /etc/init.d/xvfb
    - mode: 755
    - contents: |
        #! /bin/sh
        ### BEGIN INIT INFO
        # Provides:          Xvfb
        # Required-Start:    $remote_fs $syslog
        # Required-Stop:     $remote_fs $syslog
        # Default-Start:     2 3 4 5
        # Default-Stop:      0 1 6
        # Short-Description: Loads X Virtual Frame Buffer
        # Description:       This file should be used to construct scripts to be
        #                    placed in /etc/init.d.
        #
        #                    A virtual X server is needed to non-interactively run
        #                    'R CMD build' and 'R CMD check on some BioC packages.
        #                    The DISPLAY variable is set in /etc/profile.d/xvfb.sh.
        ### END INIT INFO
       
        XVFB=/usr/bin/Xvfb
        XVFBARGS=":1 -screen 0 800x600x16"
        PIDFILE=/var/run/xvfb.pid
        case "$1" in
          start)
            echo -n "Starting virtual X frame buffer: Xvfb"
            start-stop-daemon --start --quiet --pidfile $PIDFILE --make-pidfile --background --exec $XVFB -- $XVFBARGS
            echo "."
            ;;
          stop)
            echo -n "Stopping virtual X frame buffer: Xvfb"
            start-stop-daemon --stop --quiet --pidfile $PIDFILE

            sleep 2
            rm -f $PIDFILE
            echo "."
            ;;
          restart)
            $0 stop
            $0 start
            ;;
          *)
            echo "Usage: /etc/init.d/xvfb {start|stop|restart}"
            exit 1
        esac

        exit 0

install_init-system-helpers:
  pkg.installed:
    - name: init-system-helpers

symlink_xvfb:
  cmd.run:
    - name: update-rc.d xvfb defaults

check_xvfb_running:
  service.running:
    - name: xvfb
    - enable: True

set_xvfb_display_env:
  file.managed:
    - name: /etc/profile.d/xvfb.sh
    - mode: 644
    - contents: |
        ## Set DISPLAY environment variable for use with Xvfb.
        ## See /etc/init.d/xvfb for start / stop configuration.
        export DISPLAY=:1.0

# For installing Perl modules noninteractively
add_PERL_MM_USE_DEFAULT_to_bashrc:
  file.append:
    - name: /root/.bashrc
    - text: export PERL_MM_USE_DEFAULT=1
