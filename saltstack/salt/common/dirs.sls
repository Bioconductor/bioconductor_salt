{% set machine = salt["pillar.get"]("machine") %}
{% set build = salt["pillar.get"]("build") %}
{% set repo = salt["pillar.get"]("repo") %}
{% set r = salt["pillar.get"]("r") %}

{%- for type in build.types %}
make_{{ build.version }}_{{ type }}_directory:
  file.directory:
    - name: {{ machine.user.home }}/{{ machine.user.name }}/bbs-{{ build.version }}-{{ type }}/log
    - user: {{ machine.user.name }}
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}{{ machine.user.name }}{% endif %}
    - makedirs: True
    - replace: False
{%- endfor %}

make_{{ build.version }}_bioc_rdownloads:
  file.directory:
    - name: {{ machine.user.home }}/{{ machine.user.name }}/bbs-{{ build.version }}-bioc/rdownloads
    - user: {{ machine.user.name }}
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}{{ machine.user.name }}{% endif %}
    - makedirs: True
    - replace: False

{% if machine.type == 'primary' %}
make_public_html:
  file.directory:
    - name: {{ machine.user.home }}/{{ machine.user.name }}/public_html
    - user: {{ machine.user.name }}
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}{{ machine.user.name }}{% endif %}
    - replace: False

make_propagation_symlink:
  file.symlink:
    - name: {{ machine.user.home }}/biocpush/propagation
    - target: {{ machine.user.home }}/biocpush/BBS/propagation

{%- for build_type in build.types %}
{% if build_type != 'bioc-longtests' %}
make_{{ build_type }}_src_contrib:
  file.managed:
    - name: {{ machine.user.home }}/biocpush/PACKAGES/{{ build.version }}/{{ build_type|replace('-', '/') }}/src/contrib/PACKAGES
    - user: biocpush
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}biocpush{% endif %}
    - makedirs: True
    - dir_mode: 774
    - recurse:
      - user
      - group
      - mode

make_{{ build_type }}_bin_macosx_contrib:
  file.managed:
    - name: {{ machine.user.home }}/biocpush/PACKAGES/{{ build.version }}/{{ build_type|replace('-', '/') }}/bin/macosx/contrib/{{ r.version[2:] }}/PACKAGES
    - user: biocpush
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}biocpush{% endif %}
    - makedirs: True
    - dir_mode: 774
    - recurse:
      - user
      - group
      - mode

make_{{ build_type }}_bin_windows_contrib:
  file.managed:
    - name: {{ machine.user.home }}/biocpush/PACKAGES/{{ build.version }}/{{ build_type|replace('-', '/') }}/bin/windows/contrib/{{ r.version[2:] }}/PACKAGES
    - user: biocpush
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}biocpush{% endif %}
    - makedirs: True
    - dir_mode: 774
    - recurse:
      - user
      - group
      - mode

make_{{ build_type }}_bin_macosx_big-sur-arm64_contrib:
  file.managed:
    - name: {{ machine.user.home }}/biocpush/PACKAGES/{{ build.version }}/{{ build_type }}/bin/macosx/big-sur-arm64/contrib/{{ r.version[2:] }}/PACKAGES
    - user: biocpush
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}biocpush{% endif %}
    - makedirs: True
    - dir_mode: 774
    - recurse:
      - user
      - group
      - mode
{% endif %}
{%- endfor %}

git_bioc_manifest:
  git.cloned:
    - name: {{ repo.manifest.github }}
    - target: {{ machine.user.home }}/{{ machine.user.name }}/bbs-{{ build.version }}-bioc/{{ repo.manifest.name }}
    - user: {{ machine.user.name }}
    - branch: {{ repo.manifest.branch }}
{%- endif %}
