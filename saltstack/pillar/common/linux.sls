build:
  types:
    - bioc                  {# always required #}
    - data-annotation
    - data-experiment
    - workflows
    - books
    - long-tests

machine:
  dependencies:
    dotnet: https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
    viennarna: https://www.tbi.univie.ac.at/RNA/download/ubuntu/ubuntu_20_04/viennarna_2.4.17-1_amd64.deb
