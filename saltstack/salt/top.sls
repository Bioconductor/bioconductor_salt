base:
  'os:Ubuntu':
    - match: grain
    - common.linux
    - rlang.linux                               # install R
    - dependencies.bibtex                       # BioC destiny
    - dependencies.libsbml_cflags_libsbml_libs  # BioC rsbml
    - dependencies.xmlsimple                    # BioC LowMACA
  'os:MacOS':
    - match: grain
    - common.mac
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
  'machine:type:primary':
    - match: pillar 
    - webserver
  '*':
    - dependencies.dotnet                       # BioC rmspc
    - dependencies.ensemblvep                   # BioC ensemblVEP, MMAPPR2
    - dependencies.immunespace                  # BioC ImmuneSpaceR
    - dependencies.viennarna                    # BioC GeneGA
  'machine:env:dev':
    - match: grain
    - common.bbs
