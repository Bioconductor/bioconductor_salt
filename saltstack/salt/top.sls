base:
  'os:Ubuntu':
    - match: grain
    - common.linux
    - common.dirs
    - rlang.linux                               # install R
    - dependencies.bibtex                       # BioC destiny
    - dependencies.libsbml_cflags_libsbml_libs  # BioC rsbml
    - common.python_modules
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
    - dependencies.reticulate_python            # Bioc seqArchR
    - dependencies.rustup                       # Bioc CellBarcode
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
    - dependencies.quarto                       # Bioc BiocBook
    - dependencies.basilisk                     # Set basilisk cache location
