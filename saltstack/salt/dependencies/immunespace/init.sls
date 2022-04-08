{% set machine = salt["pillar.get"]("machine") %}
{% set immunespace = salt["pillar.get"]("immunespace") %}

{%- if machine.r_path is defined %}
{% set r_path = machine.r_path %}
{% else %}
{% set r_path = '' %}
{%- endif %}

set_ISR_login_and_ISR_pwd:
  file.append:
    - name: /etc/profile
    - text: |
        export ISR_login={{ immunespace.login }}
        export ISR_pwd={{ immunespace.pwd }}

test_R_CMD_build_ImmuneSpaceR:
  cmd.run:
    - name: |
        git clone https://git.bioconductor.org/packages/ImmuneSpaceR
        {{ r_path }}R CMD build ImmuneSpaceR
    - cwd: /tmp
    - require:
      - file: set_ISR_login_and_ISR_pwd
