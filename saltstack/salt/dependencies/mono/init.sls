# Needed by BioC rawrr

{% set machine = salt["pillar.get"]("machine") %}
{%- if machine.r_path is defined %}
{% set r_path = machine.r_path %}
{% else %}
{% set r_path = '' %}
{%- endif %}

brew_install_mono:
  cmd.run:
    - name: brew install mono

test_R_CMD_build_rawrr:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/rawrr
        {{ r_path }}/R CMD INSTALL rawrr
        {{ r_path }}/R CMD build rawrr
        ls rawrr*tar.gz | {{ r_path }}/R CMD check --no-vignettes
    - cwd: /tmp
    - require:
      - cmd: brew_install_mono
