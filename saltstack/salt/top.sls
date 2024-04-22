base:
  'os:Ubuntu':
    - match: grain
    - common.linux
    - common.dirs
    - rlang.linux                               # install R
    - dependencies.bibtex                       # BioC destiny
    - dependencies.libsbml_cflags_libsbml_libs  # BioC rsbml
  'os:MacOS':
    - match: grain
    - common.mac
    - common.dirs
    - dependencies.java                         # CRAN rJava
    - rlang.mac                                 # install R
    - dependencies.cmake                        # CRAN nloptr
    - dependencies.jags                         # BioC rjags
    - dependencies.mono                         # BioC rawrr
    - dependencies.open_babel                   # BioC ChemmineOB
    - dependencies.viennarna                    # BioC GeneGA
    - dependencies.dotnet                       # Bioc rmspc
  'machine:type:(primary|secondary)':
    - match: pillar
    - common.cronjobs
  'machine:type:primary':
    - match: pillar
    - webserver
  'machine:env:dev':
    - match: grain
    - common.bbs
  '*':
    - dependencies.reticulate_python            # Bioc seqArchR
    - dependencies.quarto                       # Bioc BiocBook
