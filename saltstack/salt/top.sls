base:
  '*':
    - common
    - common/r
  'machine:type:primary':
    - match: pillar 
    - webserver
  'dependencies:bibtex:True':                       # For destiny
    - match: pillar
    - bibtex
  'dependencies:ensemblvep:True':                   # For ensemblVEP and MMAPPR2 
    - match: pillar
    - ensemblvep 
  'dependencies:viennarna:True':                    # For GeneGA 
    - match: pillar
    - viennarna
  'dependencies:libsbml_cflags_libsbml_libs:True':  # For rsbml
    - match: pillar
    - libsbml_cflags_libsbml_libs
  'dependencies:immunespace:True':                  # For ImmuneSpaceR
    - match: pillar
    - immunespace
  'dependencies:xmlsimple:True':                    # For LowMACA
    - match: pillar
    - xmlsimple
  'dependencies:dotnet:True':			    # For rmspc 
    - match: pillar
    - dotnet
