build:
  types:
    - bioc                  {# always required #}
    - bioc-longtests
    - books
    - data-annotation
    - data-experiment
    - workflows

machine:
  dependencies:
    quarto: https://github.com/quarto-dev/quarto-cli/releases/download/v1.5.57/quarto-1.5.57-linux-amd64.deb
    viennarna: https://www.tbi.univie.ac.at/RNA/download/sourcecode/2_6_x/ViennaRNA-2.6.4.tar.gz
