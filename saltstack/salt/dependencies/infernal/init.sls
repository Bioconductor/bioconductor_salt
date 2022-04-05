# Needed by BioC inferrnal

{% set machine = salt["pillar.get"]("machine") %}
{%- if machine.r_path is defined %}
{% set r_path = machine.r_path %}
{% else %}
{% set r_path = '' %}
{%- endif %}

brew_tap_brewsci/bio:
  cmd.run:
    - name: brew tap brewsci/bio

brew_install_infernal:
  cmd.run:
    - name: brew install infernal
    - require:
      - cmd: brew_tap_brewsci/bio

test_R_CMD_build_inferrnal:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/inferrnal
        {{ r_path }}/R CMD build inferrnal
    - cwd: /tmp
    - require:
      - cmd: brew_install_infernal
