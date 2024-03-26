## Salt to Configure a Linux or Mac for the BBS

This repository contains the SaltStack formulas to configure an Ubuntu or a
MacOS machine for the [Bioconductor Build System](https://github.com/Bioconductor/BBS).

It also builds [BBS-like
containers](https://github.com/Bioconductor/bioconductor_salt/pkgs/container/bioconductor_salt).

### Simulating the BBS Ubuntu environment in a container
We are experimentally building and publishing containers under the name `ghcr.io/bioconductor/bioconductor_salt`,
which can be used to mimic a BBS-like linux environment, in hopes of easing reproducibility and interactive debugging
of the BBS environment for package developers.
We currently offer containers for both `release` and `devel` Bioconductor versions with Ubuntu `jammy` (`22.04`).
Container tags with various version pinnings can be used to acquire a particular environment, following the schema
`[ubuntu_version]-bioc-[bioc_version]-r-[r_version]` eg `jammy-bioc-3.18-r-4.3.2` or `22.04-bioc-3.18-r-4.3.2`, where
each level is optional. For example, one could use tag `jammy-bioc-3.18` or `22.04-bioc-3.18` to get the latest 3.18,
regardless of R version, or even simply `jammy`/`22.04` to get the latest release container.
`devel-` will prefix all devel container tags, followed by the same schema described above.

All containers will use the R command if no command is specified. Below are some examples for running the container.
```
# Interactive R session
docker run -it ghcr.io/bioconductor/bioconductor_salt:jammy
# is equivalent to
docker run -it ghcr.io/bioconductor/bioconductor_salt:jammy R

# Bash shell
docker run -it ghcr.io/bioconductor/bioconductor_salt:jammy bash

# Rscript
docker run -it ghcr.io/bioconductor/bioconductor_salt:jammy "Rscript --version"
```

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

Confirm that your version of R has been updated

    vagrant@nebbiolo2-dev:~$ /home/biocbuild/bbs-3.15-bioc/R/bin/R --version
    R Under development (unstable) (2021-11-16 r81199) -- "Unsuffered Consequences"

## Standalone Machine with BBS dependencies

If `machine_type` equals `standalone` in `pillar/custom/init.sls`, the machine
will be configured with the dependencies needed for the build system but without
the set up necessary to perform the official builds. A standalone build might
be sufficient for testing `R CMD INSTALL` `build` or `check`. It will also
reduce the time necessary for configuration.

Note: R will be along the `bbs-<version>-bioc/R/bin/R` path. For example, if
the current version is 3.18 then the path will be `bbs-3.18-bioc/R/bin/R`

## Salted Vagrant

### Requirements

* [Vagrant](https://vagrantup.com)

### Salted Vagrant Quick Start

1. Install Vagrant.

2. Configure the settings in the `Vagrantfile` for your system.

3. Copy `saltstack/pillar/custom/example.sls` to
   `saltstack/pillar/custom/init.sls` and edit the settings for
   your build system. Any added pillars in this file can overwrite
   other pillar values.

4. To start the VM from the repository. This step will take time if
   it is the first time.

    ```
    vagrant up
    ```

5. To access the VM

    ```
    vagrant ssh
    ```

   You will start as the `vagrant` user in the vagrant directory.

6. Before running any builds, you should change the `BBS` configuration for
   your system. If the variable `environment` is set to `dev` in the pillar,
   the BBS will automatically be configured.

   Set the number of `cores` on your system. The build process requires
   a lot of resources and power.

7. Add the builds you wish to test to the `BBS/BBSreportutils.py` function
   `display_propagation_status` to prevent propagation.

8. You can `vagrant halt` to stop the VM or `vagrant destroy` to remove it.

### Running builds in Vagrant

After the VM is running and Salt has reached a high state, you can run a build;
however, you may want to edit file in the manifest for the packages you want to
build. You should include the package and its dependencies. The following example
assumes you're running 3.14 software builds.

    sudo su - biocbuild
    cd ~/bbs-3.14-bioc/manifest
    # edit /home/biocbuild/bbs-3.14-bioc/manifest/software.txt
    # prerun of build
    cd /home/biocbuild/BBS/3.14/bioc/`hostname` && ./prerun.sh
    >>/home/biocbuild/bbs-3.14-bioc/log/`hostname`-`date +\%Y\%m\%d`-prerun.log 2>&1
    # Run of build
    cd /home/biocbuild/BBS/3.14/bioc/`hostname` && ./run.sh
    >>/home/biocbuild/bbs-3.14-bioc/log/`hostname`-`date +\%Y\%m\%d`-run.log 2>&1
    # Postrun of build
    cd /home/biocbuild/BBS/3.14/bioc/`hostname` && ./postrun.sh
    >>/home/biocbuild/bbs-3.14-bioc/log/`hostname`-`date +\%Y\%m\%d`-postrun.log 2>&1

    # You may want to check the log of each section; for example
    tail -f ~/bbs-3.14-bioc/log/nebbiolo2-20211022-run.log

See `https://github.com/Bioconductor/BBS/blob/master/Doc/Prepare-Ubuntu-20.04-HOWTO.md`
for more information on builds.

## Notes

- When using the VM, access the `biocbuild` user with `sudo su - biocbuild`
  to preserve environmental variables.
- The prerun script will attempt to update the `manifest`, so you should
  update your `manifest` repository first then edit the file corresponding to
  the build you plan run.
- You may want to increase the memory in the Vagrantfile if you plan to build
  several packages.
- Still having issues installing Bioc package `MMAPPR2`.
