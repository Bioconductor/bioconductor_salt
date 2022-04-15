{% set machine = salt["pillar.get"]("machine") %}
{% set build = salt["pillar.get"]("build") %}
{% set repo = salt["pillar.get"]("repo") %}

{%- for type in build.types %}
make_{{ build.version }}_{{ type }}_directory:
  file.directory:
    - name: {{ machine.user.home }}/biocbuild/bbs-{{ build.version }}-{{ type }}/log
    - user: biocbuild
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}biocbuild{% endif %}
    - makedirs: True
    - replace: False
{%- endfor %}

make_{{ build.version }}_bioc_rdownloads:
  file.directory:
    - name: {{ machine.user.home }}/biocbuild/bbs-{{ build.version }}-bioc/rdownloads
    - user: biocbuild
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}biocbuild{% endif %}
    - makedirs: True
    - replace: False

{% if machine.type == 'primary' %}
make_public_html:
  file.directory:
    - name: {{ machine.user.home }}/biocbuild/public_html
    - user: biocbuild
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}biocbuild{% endif %}
    - replace: False

make_propagation_symlink:
  file.symlink:
    - name: {{ machine.user.home }}/biocpush/propagation
    - target: {{ machine.user.home }}/biocpush/BBS/propagation

{%- for build_type in build.types %}
make_{{ build_type }}_src_contrib:
  file.directory:
    - name: {{ machine.user.home }}/biocpush/PACKAGES/{{ build.version }}/{{ build_type }}/src/contrib
    - user: biocpush
    - group: {% if grains['os'] == 'MacOS' %}staff{% else %}biocbuild{% endif %}
    - makedirs: True
    - dir_mode: 774
    - recurse:
      - user
      - group
      - mode
{%- endfor %}

git_bioc_manifest:
  git.cloned:
    - name: {{ repo.manifest.github }}
    - target: {{ machine.user.home }}/biocbuild/bbs-{{ build.version }}-bioc/{{ repo.manifest.name }}
    - user: biocbuild 
    - branch: {{ repo.manifest.branch }}
{%- endif %}
