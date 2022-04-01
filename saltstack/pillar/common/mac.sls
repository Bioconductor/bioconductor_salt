build:
  types:
    - bioc                  {# always required #}

machine:
  downloads:
    gfortran: https://github.com/fxcoudert/gfortran-for-macOS/releases/download/11.2-monterey-intel/gfortran-Intel-11.2-Monterey.dmg
    mactex: https://mirror.ctan.org/systems/mac/mactex/MacTeX.pkg
    pandoc: https://github.com/jgm/pandoc/releases/download/2.17.1.1/pandoc-2.17.1.1-macOS.pkg
    xquartz: https://github.com/XQuartz/XQuartz/releases/download/XQuartz-2.8.1/XQuartz-2.8.1.dmg
  brews: openssl@3 python@3 xz wget pstree 

r:
  cran:
    - rgl
    - Rcpp
    - minqa
    - Cairo
    - devtools
  bioc:
    - BiocCheck
    - BiocStyle
    - rtracklayer
    - VariantAnnotation
    - rhdf5
  difficult_pkgs:
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
