build:
  types:
    - bioc                  {# always required #}

machine:
  brews: openssl@3 python@3 xz wget pstree
  dependencies:             {# For Bioc or CRAN packages #}
    clustal_omega: http://www.clustal.org/omega/clustal-omega-1.2.3-macosx
    cmake: https://github.com/Kitware/CMake/releases/download/v3.23.0/cmake-3.23.0-macos-universal.dmg
    dotnet: https://download.visualstudio.microsoft.com/download/pr/2a70a8b8-e0e7-4ccc-940b-d73b375b0636/75422fdccd9e762cc0c3176424779181/dotnet-runtime-6.0.3-osx-x64.pkg      {# .NET runtime installer #}
    gsl: https://mac.r-project.org/bin/darwin17/x86_64/gsl-2.7-darwin.17-x86_64.tar.xz
    hdf5: https://mac.r-project.org/bin/darwin17/x86_64/hdf5-1.12.1-darwin.17-x86_64.tar.xz
    jags: https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Mac%20OS%20X/JAGS-4.3.0.dmg
    java_x64: https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_macos-x64_bin.tar.gz
    java_aarch64: https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_macos-aarch64_bin.tar.gz
    macfuse: https://github.com/osxfuse/osxfuse/releases/download/macfuse-4.2.4/macfuse-4.2.4.dmg
    netcdf: https://mac.r-project.org/bin/darwin17/x86_64/netcdf-4.8.1-darwin.17-x86_64.tar.xz
    viennarna: https://www.tbi.univie.ac.at/RNA/download/osx/macosx/ViennaRNA-2.5.0-MacOSX.dmg
  downloads:                {# For BBS #}
    intel:
      gfortran: https://github.com/fxcoudert/gfortran-for-macOS/releases/download/11.2-monterey-intel/gfortran-Intel-11.2-Monterey.dmg
      pandoc: https://github.com/jgm/pandoc/releases/download/2.18/pandoc-2.18-macOS.pkg
    arm64:
      gfortran: https://github.com/fxcoudert/gfortran-for-macOS/releases/download/12.1-monterey/gfortran-ARM-12.1-Monterey.dmg
    mactex: https://mirror.ctan.org/systems/mac/mactex/MacTeX.pkg
    xquartz: https://github.com/XQuartz/XQuartz/releases/download/XQuartz-2.8.1/XQuartz-2.8.1.dmg

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
