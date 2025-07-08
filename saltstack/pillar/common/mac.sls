build:
  types:
    - bioc                  {# always required #}
    - bioc-longtests
    - workflows

machine:
  binaries:
    - gsl
    - glpk
    - openssl
    - pkgconfig
    - xz
  brews: pstree
  dependencies:             {# For Bioc or CRAN packages #}
    arm64:
      dotnet: https://download.visualstudio.microsoft.com/download/pr/c17c9c8a-11dc-41b4-975f-89b5b101a0e3/dbefaaf56c7388afb76cc96c76a13316/dotnet-runtime-9.0.3-osx-arm64.pkg
      java: https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_macos-aarch64_bin.tar.gz 
    intel:
      dotnet: https://download.visualstudio.microsoft.com/download/pr/e59ade14-21cb-4303-8875-69373a17234c/fdd434f76c113afae01211b02470c302/dotnet-runtime-9.0.3-osx-x64.pkg
      java: https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_macos-x64_bin.tar.gz 
    cmake: https://github.com/Kitware/CMake/releases/download/v3.31.1/cmake-3.31.1-macos-universal.tar.gz
    jags: https://cfhcable.dl.sourceforge.net/project/mcmc-jags/JAGS/4.x/Mac%20OS%20X/JAGS-4.3.1.pkg
    quarto: https://github.com/quarto-dev/quarto-cli/releases/download/v1.7.32/quarto-1.7.32-macos.pkg
    viennarna: https://www.tbi.univie.ac.at/RNA/download/osx/macosx/ViennaRNA-2.5.0-MacOSX.dmg
  downloads:                {# For BBS #}
    intel:
      pandoc: https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-macOS.pkg
    gfortran: https://github.com/R-macos/gcc-14-branch/releases/download/gcc-14.2-darwin-r2.1/gfortran-14.2-darwin20-r2-universal.tar.xz
    mactex: https://mirror.ctan.org/systems/mac/mactex/MacTeX.pkg
    xquartz: https://github.com/XQuartz/XQuartz/releases/download/XQuartz-2.8.5/XQuartz-2.8.5.pkg
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
    - redux
    - qqconf
