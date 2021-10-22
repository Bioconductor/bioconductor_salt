{% set immunespace = salt["pillar.get"]("immunespace") %}

set_ISR_login_and_ISR_pwd:
  file.append:
    - name: /etc/profile
    - text: |
        export ISR_login={{ immunespace.login }}
        export ISR_pwd={{ immunespace.pwd }}
