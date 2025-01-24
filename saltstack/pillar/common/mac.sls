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
      dotnet: https://download.visualstudio.microsoft.com/download/pr/99a222a4-b8fb-4d19-a91a-a69aeaf9ba06/fdd439f0dc45cb1357b03a30e2bc8f98/dotnet-runtime-6.0.29-osx-arm64.pkg
      java: https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_macos-aarch64_bin.tar.gz 
    intel:
      dotnet: https://download.visualstudio.microsoft.com/download/pr/8583970d-ca62-4053-9b25-01c2d2742062/8a5c9a04863a80655f483d67c3725255/dotnet-runtime-6.0.29-osx-x64.pkg
      java: https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_macos-x64_bin.tar.gz 
    cmake: https://github.com/Kitware/CMake/releases/download/v3.31.1/cmake-3.31.1-macos-universal.tar.gz
    jags: https://cfhcable.dl.sourceforge.net/project/mcmc-jags/JAGS/4.x/Mac%20OS%20X/JAGS-4.3.1.pkg
    quarto: https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.553/quarto-1.4.553-macos.pkg 
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
