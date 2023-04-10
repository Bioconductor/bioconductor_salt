build:
  types:
    - bioc                  {# always required #}

machine:
  brews: xz pstree poppler
  dependencies:             {# For Bioc or CRAN packages #}
    arm64:
      dotnet: https://download.visualstudio.microsoft.com/download/pr/aa3b3150-80cb-4d30-87f8-dc36fa1dcf26/8ec9ff6836828175f1a6a60aefd4e63b/dotnet-runtime-6.0.13-osx-arm64.pkg
      gsl: https://mac.r-project.org/bin/darwin20/arm64/gsl-2.7-darwin.20-arm64.tar.xz
      hdf5: https://mac.r-project.org/bin/darwin20/arm64/hdf5-1.12.1-darwin.20-arm64.tar.xz
      java: https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_macos-aarch64_bin.tar.gz
      netcdf: https://mac.r-project.org/bin/darwin20/arm64/netcdf-4.8.1-darwin.20-arm64.tar.xz
    intel:
      dotnet: https://download.visualstudio.microsoft.com/download/pr/2ef12357-499b-4a5b-a488-da45a5f310e6/fbe35c354bfb50934a976fc91c6d8d81/dotnet-runtime-6.0.13-osx-x64.pkg
      gsl: https://mac.r-project.org/bin/darwin17/x86_64/gsl-2.7-darwin.17-x86_64.tar.xz
      hdf5: https://mac.r-project.org/bin/darwin17/x86_64/hdf5-1.12.1-darwin.17-x86_64.tar.xz
      java: https://download.java.net/java/GA/jdk18.0.1.1/65ae32619e2f40f3a9af3af1851d6e19/2/GPL/openjdk-18.0.1.1_macos-x64_bin.tar.gz
      netcdf: https://mac.r-project.org/bin/darwin17/x86_64/netcdf-4.8.1-darwin.17-x86_64.tar.xz
    clustal_omega: http://www.clustal.org/omega/clustal-omega-1.2.3-macosx
    cmake: https://github.com/Kitware/CMake/releases/download/v3.23.0/cmake-3.23.0-macos-universal.dmg
    jags: https://cfhcable.dl.sourceforge.net/project/mcmc-jags/JAGS/4.x/Mac%20OS%20X/JAGS-4.3.1.pkg
    macfuse: https://github.com/osxfuse/osxfuse/releases/download/macfuse-4.2.4/macfuse-4.2.4.dmg
    viennarna: https://www.tbi.univie.ac.at/RNA/download/osx/macosx/ViennaRNA-2.5.0-MacOSX.dmg
    glpk: https://mac.r-project.org/bin/darwin20/x86_64/glpk-5.0-darwin.20-x86_64.tar.xz
  downloads:                {# For BBS #}
    intel:
      pandoc: https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-macOS.pkg
    gfortran: https://github.com/R-macos/gcc-12-branch/releases/download/12.2-darwin-r0/gfortran-12.2-darwin20-r0-universal.tar.xz
    mactex: https://mirror.ctan.org/systems/mac/mactex/MacTeX.pkg
    pkgconfig: https://mac.r-project.org/bin/darwin20/x86_64/pkgconfig-0.29.2-darwin.20-x86_64.tar.xz
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
