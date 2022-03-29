{# Custom Settings #}

{% set branch = 'release' %}                                {# Use 'release' or 'devel' #}
{% set version = '3.14' %}                                  {# Bioc version #}
{% set environment = 'dev' %}                               {# Use 'dev' or 'prod' #}
{% set r_download = 'https://cran.r-project.org/src/base/R-4/R-4.1.1.tar.gz' %}
{% set r_version = 'R-4.1.1' %}
{% set cycle = 'patch' %}                                   {# Use 'devel' for Spring to Fall, 'patch' for Fall to Spring #}
{% set name = 'nebbiolo2' %}                                {# nebbiolo1 for 3.15, nebbiolo2 for 3.14 #}
{% set biocbuild_password = 'PASSWORD' %}
{% set biocbuild_key = 'salt://common/files/id_rsa' %}      {# Path to the file #}
{% set biocbuild_authorized_key = 'ssh-rsa AAAiB3Nza== biocbuild@nebbiolo2' %}
{% set biocpush_password = 'PASSWORD' %}
{% set biocpush_key = 'salt://common/files/id_rsa' %}
{% set biocpush_authorized_key = 'ssh-rsa AAAiB3Nza== biocpush@nebbiolo2' %}
{% set immunespace_pwd = 'PASSWORD' %}                      {# Need for ImmuneSpaceR #}

{# Add any pillars to overwrite existing values #}

{# Bioc package dependencies #}

dependencies:
  bibtex: True                                              {# for bioc destiny #}
  ensemblvep: True                                          {# for bioc ensemblVEP and MMAPPR2 #}
  viennarna: True                                           {# for bioc GeneGA #}
  libsbml_cflags_libsbml_libs: True                         {# for bioc rsbml #}
  immunespace: True                                         {# for bioc ImmuneSpaceR #}
  xmlsimple: True                                           {# for bioc LowMACA #}
  dotnet: True                                              {# for bioc rmspc #}

{# Add users and groups #}

{# Add more groups and users using the same pattern below
 # then remove the comments
machine:
  additional:
    groups:
      - newGroup
    users:
      - name: newMember
        pub-key: "ssh AAAAA newMember"
        password: PASSWORD
        groups:
          - newGroup
#}
