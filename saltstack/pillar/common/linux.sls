{% from '../custom/init.sls' import version %}
{% from 'common/init.sls' import user_home %}

build:
  types:
    - bioc                  {# always required #}
    - data-annotation
    - data-experiment
    - workflows
    - books
    - long-tests
  cron:
    jobs:
      - name: bioc_prerun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./prerun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-prerun.log 2>&1"
        user: biocbuild
        minute: 55
        hour: 13
        daymonth: "*"
        month: "*"
        dayweek: "0-5"
        comment: "BIOC {{ version }} SOFTWARE BUILDS prerun"
        commented: True
      - name: bioc_run
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./run.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-run.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 15
        daymonth: "*"
        month: "*"
        dayweek: "0-5"
        comment: "BIOC {{ version }} SOFTWARE BUILDS run"
        commented: True
      - name: bioc_postrun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./postrun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-postrun.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 11
        daymonth: "*"
        month: "*"
        dayweek: "1-6"
        comment: "BIOC {{ version }} SOFTWARE BUILDS postrun"
        commented: True
      - name: bioc_notify
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./stage7-notify.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-notify.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 13
        daymonth: "*"
        month: "*"
        dayweek: "3"
        comment: "BIOC {{ version }} SOFTWARE BUILDS notify"
        commented: True
      - name: data-annotation_prerun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/data-annotation/`hostname` && ./prerun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-data-annotation/log/`hostname`-`date +\%Y\%m\%d`-prerun.log 2>&1"
        user: biocbuild
        minute: 30
        hour: 02
        daymonth: "*"
        month: "*"
        dayweek: 3
        comment: "BIOC {{ version }} DATA ANNOTATION BUILDS prerun"
        commented: True
      - name: data-annotation_run
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/data-annotation/`hostname` && ./run.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-data-annotation/log/`hostname`-`date +\%Y\%m\%d`-run.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 03
        daymonth: "*"
        month: "*"
        dayweek: 3
        comment: "BIOC {{ version }} DATA ANNOTATION BUILDS run"
        commented: True
      - name: data-annotation_postrun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/data-annotation/`hostname` && ./postrun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-data-annotation/log/`hostname`-`date +\%Y\%m\%d`-postrun.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 06
        daymonth: "*"
        month: "*"
        dayweek: 3
        comment: "BIOC {{ version }} DATA ANNOTATION BUILDS postrun"
        commented: True
      - name: data-experiment_prerun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/data-experiment/`hostname` && ./prerun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-data-experiment/log/`hostname`-`date +\%Y\%m\%d`-prerun.log 2>&1"
        user: biocbuild
        minute: 30
        hour: 07
        daymonth: "*"
        month: "*"
        dayweek: "2,4"
        comment: "BIOC {{ version }} DATA EXPERIMENT BUILDS prerun"
        commented: True
      - name: data-experiment_run
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/data-experiment/`hostname` && ./run.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-data-experiment/log/`hostname`-`date +\%Y\%m\%d`-run.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 10
        daymonth: "*"
        month: "*"
        dayweek: "2,4"
        comment: "BIOC {{ version }} DATA EXPERIMENT BUILDS run"
        commented: True
      - name: data-experiment_postrun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/data-experiment/`hostname` && ./postrun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-data-experiment/log/`hostname`-`date +\%Y\%m\%d`-postrun.log 2>&1"
        user: biocbuild
        minute: 45
        hour: 14
        daymonth: "*"
        month: "*"
        dayweek: "2,4"
        comment: "BIOC {{ version }} DATA EXPERIMENT BUILDS postrun"
        commented: True
      - name: workflows_prerun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/workflows/`hostname` && ./prerun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-workflows/log/`hostname`-`date +\%Y\%m\%d`-prerun.log 2>&1"
        user: biocbuild
        minute: 45
        hour: 07
        daymonth: "*"
        month: "*"
        dayweek: "2,5"
        comment: "BIOC {{ version }} WORKFLOWS BUILDS prerun"
        commented: True
      - name: workflows_run
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/workflows/`hostname` && ./run.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-workflows/log/`hostname`-`date +\%Y\%m\%d`-run.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 08
        daymonth: "*"
        month: "*"
        dayweek: "2,5"
        comment: "BIOC {{ version }} WORKFLOWS BUILDS run"
        commented: True
      - name: workflows_postrun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/workflows/`hostname` && ./postrun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-workflows/log/`hostname`-`date +\%Y\%m\%d`-postrun.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 14
        daymonth: "*"
        month: "*"
        dayweek: "2,5"
        comment: "BIOC {{ version }} WORKFLOWS BUILDS postrun"
        commented: True
      - name: books_prerun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/books/`hostname` && ./prerun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-books/log/`hostname`-`date +\%Y\%m\%d`-prerun.log 2>&1"
        user: biocbuild
        minute: 45
        hour: 06
        daymonth: "*"
        month: "*"
        dayweek: "1,3,5"
        comment: "BIOC {{ version }} BOOKS BUILDS prerun"
        commented: True
      - name: books_run
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/books/`hostname` && ./run.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-books/log/`hostname`-`date +\%Y\%m\%d`-run.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 07
        daymonth: "*"
        month: "*"
        dayweek: "1,3,5"
        comment: "BIOC {{ version }} BOOKS BUILDS run"
        commented: True
      - name: books_postrun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/books/`hostname` && ./postrun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-books/log/`hostname`-`date +\%Y\%m\%d`-postrun.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 14
        daymonth: "*"
        month: "*"
        dayweek: "1,3,5"
        comment: "BIOC {{ version }} BOOKS BUILDS postrun"
        commented: True
      - name: bioc-longruns_prerun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc-longruns/`hostname` && ./prerun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc-longruns/log/`hostname`-`date +\%Y\%m\%d`-prerun.log 2>&1"
        user: biocbuild
        minute: 55
        hour: 06
        daymonth: "*"
        month: "*"
        dayweek: 6
        comment: "BIOC {{ version }} BIOC-LONGRUNS BUILDS prerun"
        commented: True
      - name: bioc-longruns_run
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc-longruns/`hostname` && ./run.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc-longruns/log/`hostname`-`date +\%Y\%m\%d`-run.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 08
        daymonth: "*"
        month: "*"
        dayweek: 6
        comment: "BIOC {{ version }} BIOC-LONGRUNS BUILDS run"
        commented: True
      - name: bioc-longruns_postrun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc-longruns/`hostname` && ./postrun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc-longruns/log/`hostname`-`date +\%Y\%m\%d`-postrun.log 2>&1"
        user: biocbuild
        minute: 00
        hour: 21
        daymonth: "*"
        month: "*"
        dayweek: 6
        comment: "BIOC {{ version }} BIOC-LONGRUNS BUILDS postrun"
        commented: True

machine:
  dependencies:
    dotnet: https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
    viennarna: https://www.tbi.univie.ac.at/RNA/download/ubuntu/ubuntu_20_04/viennarna_2.4.17-1_amd64.deb
