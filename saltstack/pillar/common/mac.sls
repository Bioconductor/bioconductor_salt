{% from '../custom/.sls' import user_home, version %}

build:
  types:
    - bioc                  {# always required #}
  cron:
    user: biocbuild
    path: /usr/local/bin:/usr/bin:/bin
    jobs:
      - name: bioc_prerun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./prerun.sh >> {{ user_home}} /biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-prerun.log 2>&1"
        minute: 50
        hour: 14
        daymonth: "*"
        month: "*"
        dayweek: "0-5"
        comment: "BIOC {{ version }} SOFTWARE BUILDS"
        commented: True 
      - name: bioc_run
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./run.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-run.log 2>&1"
        minute: 00
        hour: 16
        daymonth: "*"
        month: "*"
        dayweek: "0-5"
        comment: "BIOC {{ version }} SOFTWARE BUILDS"
        commented: True 
      - name: bioc_postrun
        command: /bin/bash --login -c "cd {{ user_home }}/biocbuild/BBS/{{ version }}/bioc/`hostname` && ./postrun.sh >> {{ user_home }}/biocbuild/bbs-{{ version }}-bioc/log/`hostname`-`date +\%Y\%m\%d`-postrun.log 2>&1"
        minute: 00
        hour: 12
        daymonth: "*"
        month: "*"
        dayweek: "1-6"
        comment: "BIOC {{ version }} SOFTWARE BUILDS"
        commented: True 

machine:
  downloads:
    gfortran: https://github.com/fxcoudert/gfortran-for-macOS/releases/download/11.2-monterey-intel/gfortran-Intel-11.2-Monterey.dmg
    mactex: https://mirror.ctan.org/systems/mac/mactex/MacTeX.pkg
    pandoc: https://github.com/jgm/pandoc/releases/download/2.17.1.1/pandoc-2.17.1.1-macOS.pkg
    xquartz: https://github.com/XQuartz/XQuartz/releases/download/XQuartz-2.8.1/XQuartz-2.8.1.dmg
  brews: openssl@3 python@3 xz wget pstree 

r:
  difficult-pkgs:
    - XML
    - rJava
    - gdtools
    - units
    - gsl
    - V8
    - magick
    - rsvg
    - gmp
    - xml2
    - jpeg
    - tiff
    - ncdf4
    - fftw
    - fftwtools
    - proj4
    - textshaping
    - ragg
    - Rmpfr
    - pdftools
    - av
    - rgeos
    - sf
    - RcppAlgos
    - glpkAPI
    - gert
    - RPostgres
    - RMySQL
    - RMariaDB
    - protolite
    - arrangements
    - terra
    - PoissonBinomial
    - igraph
