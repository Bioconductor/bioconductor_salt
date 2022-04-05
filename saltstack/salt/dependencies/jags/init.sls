# Needed for rjags

{% set machine = salt["pillar.get"]("machine") %}
{% set download = machine.dependencies.jags.split("/")[-1] %}
{% set jags = jags[-4] %}

download_jags:
  cmd.run:
    - name: curl -LO {{ machine.dependencies.jags }}
    - cwd:  {{ machine.user.home }}/Downloads
    - user: biocbuild

install_jags:
  cmd.run:
    - name: |
        hdiutil attach {{ download }}
        installer -pkg /Volumes/{{ jags }}/{{ jags }}.pkg -target /
        hdiutil detach /Volumes/{{ jags }}
    - require:
      - cmd: download_jags

fix_/usr/local_permissions_jags:
  cmd.run:
    - name: |
        chown -R biocbuild:admin /usr/local/*
        chown -R root:wheel /usr/local/texlive
    - require:
      - cmd: install_jags

test_rjags_install:
  cmd.run:
    - name: Rscript -e 'install.packages("rjags", type="source", repos="https://cran.r-project.org")'
