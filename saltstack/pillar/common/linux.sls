build:
  types:
    - bioc                  {# always required #}
    - bioc-gpu
    - bioc-longtests
    - books
    - data-annotation
    - data-experiment
    - workflows

machine:
  dependencies:
    quarto: https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.43/quarto-1.6.43-linux-amd64.deb
    viennarna: https://www.tbi.univie.ac.at/RNA/download/sourcecode/2_6_x/ViennaRNA-2.6.4.tar.gz
