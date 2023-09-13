{% set build = salt["pillar.get"]("build") %}

{%- for job in build.cron.jobs %}
add_{{ job.name }}_crontab:
  cron.present:
    - name: {{ job.command}}
    - user: {{ job.user }}
    - minute: "{{ job.minute }}"
    - hour: "{{ job.hour }}"
    - daymonth: "{{ job.daymonth }}"
    - month: "{{ job.month }}"
    - dayweek: "{{ job.dayweek }}"
    - comment: {{ job.comment }}
    - commented: {{ job.commented }}
{%- endfor %}
