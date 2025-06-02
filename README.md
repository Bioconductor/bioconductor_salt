## Salt to Configure a Linux or Mac for the BBS

This repository contains the SaltStack formulas to configure an Ubuntu or a
MacOS machine for the [Bioconductor Build System](https://github.com/Bioconductor/BBS).

It also builds [BBS-like
containers](https://github.com/Bioconductor/bioconductor_salt/pkgs/container/bioconductor_salt).

### Simulating the BBS Ubuntu environment in a container

We are building and publishing containers under the name `ghcr.io/bioconductor/bioconductor_salt`,
which can be used to mimic a BBS-like linux environment, in hopes of easing reproducibility and interactive debugging
of the BBS environment for package developers.

We currently offer containers for both `release` and `devel` Bioconductor versions with Ubuntu `noble` (`24.04`).
Container tags with various version pinnings can be used to acquire a particular environment, following the schema
`[ubuntu_version]-bioc-[bioc_version]-r-[r_version]` eg `noble-bioc-3.22-r-4.5.0` or `24.04-bioc-3.22-r-4.5.0, where
each level is optional. For example, one could use tag `noble-bioc-3.22` or `24.04-bioc-3.22` to get the latest 3.22,
regardless of R version, or even simply `noble`/`24.04` to get the latest release container.
`devel-` will prefix all devel container tags, followed by the same schema described above.

All containers will use the R command if no command is specified. Below are some examples for running the container.
```
# Interactive R session
docker run -it ghcr.io/bioconductor/bioconductor_salt:noble
# is equivalent to
docker run -it ghcr.io/bioconductor/bioconductor_salt:noble R

# Bash shell
docker run -it ghcr.io/bioconductor/bioconductor_salt:noble bash

# Rscript
docker run -it ghcr.io/bioconductor/bioconductor_salt:noble "Rscript --version"
```

We are also experimentally building BBS-like containers based on Nvidia
containers, which can be run as

```
docker run --gpus all -it ghcr.io/bioconductor/bioconductor_salt:devel-nvidia-noble R
```

#### Note for containers with an Nvidia base

This software contains source code provided by NVIDIA Corporation.

These containers are subject to
https://developer.download.nvidia.com/licenses/NVIDIA_Deep_Learning_Container_License.pdf.


### Configuring for Ubuntu 22.04

1. On the build machine, install the Salt minion and clone this repository:
    ```
    sudo apt install salt-minion
    ```
Note: If the minion is running as a daemon, you'll want to stop it as it will
poll for the master periodically.

2. Copy `saltstack/minion.d/minion.conf` to `/etc/salt/minion`.

3. Copy the files in `/saltstack` to `/srv`.

4. Copy ssh keys to `/srv/salt/common/files`.

5. Comment add or remove any dependencies not needed for your system in
`/opt/salt/top.sls`.

6. Run salt, with debug or testing (`test=True`) if desired:

    ```
    sudo salt-call --local state.highstate -l debug
    ```

7. Configure the `BBS` configuration files.

8. Uncomment the desired builds in the crontab as `biocbuild`.

### Configuring a Mac

1. On the build machine, install Saltstack by downloading the file corresponding
to your OS at
https://docs.saltproject.io/salt/install-guide/en/latest/topics/install-by-operating-system/macos.html.

For example

    ```
    curl -LO https://repo.saltproject.io/salt/py3/macos/latest/salt-3007.0-py3-x86_64.pkg
    sudo installer -verbose -pkg salt-3007.0-py3-x86_64.pkg -target /
    ```

Log out and log back in then check if `salt-call` is available with `which salt-call`.

2. Copy `saltstack/minion.d/mac.minion.conf` to `/etc/salt/minion`.

3. Copy `saltstack` to `/opt`.

4. Copy ssh keys to `/opt/saltstack/salt/common/files`.

5. Comment add or remove any dependencies not needed for your system
in `/opt/saltstack/salt/top.sls`.

6. If creating user `biocbuild`, set the password in an environment
variable:

    export BIOCBUILD_PASSWORD=myNewPass1

7. Run salt, with debug or testing (`test=True`) if desired:

    ```
    sudo salt-call --local state.highstate -l debug
    ```

8. Configure the BBS configuration files.

9. Uncomment the desired builds in the crontab as `biocbuild`.

## Updating R

Note: If macFuse is needed and it will be installed on the machine for the
first time, you may need to enable kernel support for third party extensions.
See https://github.com/macfuse/macfuse/wiki/Getting-Started.

You may also run individual states, such as to update R. After configuring the
`custom` file for your machine, run the `rlang` states for your machine.

Replace the url for `r_download` with the new version of R in
`saltstack/pillar/custom/init.sls`:

    {% set branch = 'dev' %} {# Use 'release' or 'devel' #}
    {% set version = '3.15' %}
    {% set environment = 'dev' %} {# Use 'dev' or 'prod' #}
    {% set r_download = 'https://stat.ethz.ch/R/daily/R-devel_2021-11-16.tar.gz' %}
    {% set r_version = 'R-4.1.2' %}
    {% set cycle = 'patch' %} {# Use 'devel' for Spring to Fall, 'patch' for Fall to Spring #}

Update any related variables, such as `r_version`. To perform the update, run

    sudo salt-call --local state.apply rlang.linux

## Standalone Machine with BBS dependencies

If `machine_type` equals `standalone` in `pillar/custom/init.sls`, the machine
will be configured with the dependencies needed for the build system but without
the set up necessary to perform the official builds. A standalone build might
be sufficient for testing `R CMD INSTALL` `build` or `check`. It will also
reduce the time necessary for configuration.
