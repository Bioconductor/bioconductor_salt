# Needed for CRAN Rmpi

brew_open_mpi:
  cmd.run:
    - name: brew install open-mpi 
    - user: biocbuild

test_cran_install_Rmpi:
  cmd.run:
    - name: |
        Rscript -e 'install.packages("Rmpi", type="source", repos="https://cran.r-project.org");
        library(Rmpi); mpi.spawn.Rslaves(nslaves=3); mpi.parReplicate(100, mean(rnorm(1000000)));
        mpi.close.Rslaves(); mpi.quit()'
    - require:
      - cmd: brew_open_mpi
