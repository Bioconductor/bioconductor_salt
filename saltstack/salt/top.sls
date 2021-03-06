base:
  'os:Ubuntu':
    - match: grain
    - common.linux
    - common.dirs
    - rlang.linux                               # install R
    - dependencies.bibtex                       # BioC destiny
    - dependencies.libsbml_cflags_libsbml_libs  # BioC rsbml
    - dependencies.xmlsimple                    # BioC LowMACA
  'os:MacOS':
    - match: grain
    - common.mac
    - common.dirs
    - dependencies.java                         # CRAN rJava
    - rlang.mac                                 # install R
    - dependencies.clustal_omega                # BioC LowMACA
    - dependencies.cmake                        # CRAN nlopter
    - dependencies.gsl                          # BioC GLAD
    - dependencies.infernal                     # BioC inferrnal
    - dependencies.jags                         # BioC rjags
    - dependencies.macfuse                      # BioC Travel
    - dependencies.mono                         # BioC rawrr
    - dependencies.mysql                        # BioC ensemblVEP
    - dependencies.netcdf_hdf5                  # CRAN ncdf4, BioC mzR
    - dependencies.open_babel                   # BioC ChemmineOB
    - dependencies.open_mpi                     # CRAN Rmpi
  '*':
    - common.cronjobs
    - dependencies.dotnet                       # BioC rmspc
    - dependencies.ensemblvep                   # BioC ensemblVEP, MMAPPR2
    - dependencies.immunespace                  # BioC ImmuneSpaceR
    - dependencies.viennarna                    # BioC GeneGA
  'machine:type:primary':
    - match: pillar
    - webserver
  'machine:env:dev':
    - match: grain
    - common.bbs
