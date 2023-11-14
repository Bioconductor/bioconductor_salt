build:
  types:
    - bioc                  {# always required #}

machine:
  dependencies:
    dotnet: https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
    quarto: https://github.com/quarto-dev/quarto-cli/releases/download/v1.3.450/quarto-1.3.450-linux-amd64.deb
    viennarna: https://www.tbi.univie.ac.at/RNA/download/ubuntu/ubuntu_20_04/viennarna_2.4.17-1_amd64.deb
