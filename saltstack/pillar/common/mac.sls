build:
  types:
    - bioc                  {# always required #}

machine:
  binaries:
    - gsl
    - glpk
    - openssl
    - pkgconfig
    - xz
  brews: pstree poppler
  dependencies:             {# For Bioc or CRAN packages #}
    arm64:
      dotnet: https://download.visualstudio.microsoft.com/download/pr/aa3b3150-80cb-4d30-87f8-dc36fa1dcf26/8ec9ff6836828175f1a6a60aefd4e63b/dotnet-runtime-6.0.13-osx-arm64.pkg
      java: https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_macos-aarch64_bin.tar.gz 
    intel:
      dotnet: https://download.visualstudio.microsoft.com/download/pr/2ef12357-499b-4a5b-a488-da45a5f310e6/fbe35c354bfb50934a976fc91c6d8d81/dotnet-runtime-6.0.13-osx-x64.pkg
      java: https://download.java.net/java/GA/jdk21/fd2272bbf8e04c3dbaee13770090416c/35/GPL/openjdk-21_macos-x64_bin.tar.gz 
    clustal_omega: http://www.clustal.org/omega/clustal-omega-1.2.3-macosx
    cmake: https://github.com/Kitware/CMake/releases/download/v3.23.0/cmake-3.23.0-macos-universal.dmg
    jags: https://cfhcable.dl.sourceforge.net/project/mcmc-jags/JAGS/4.x/Mac%20OS%20X/JAGS-4.3.1.pkg
    macfuse: https://github.com/osxfuse/osxfuse/releases/download/macfuse-4.5.0/macfuse-4.5.0.dmg
    viennarna: https://www.tbi.univie.ac.at/RNA/download/osx/macosx/ViennaRNA-2.5.0-MacOSX.dmg
  downloads:                {# For BBS #}
    intel:
      pandoc: https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-macOS.pkg
    gfortran: https://github.com/R-macos/gcc-12-branch/releases/download/12.2-darwin-r0/gfortran-12.2-darwin20-r0-universal.tar.xz
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
