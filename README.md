## Salt to Configure a Linux or Mac for the BBS

The available SaltStack formulas can be used to configure an Ubuntu or a
MacOS machine.

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

1. On the build machine, install Saltstack with `homebrew`
and clone this repository:
    ```
    brew install saltstack
    ```

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

Note: Saltstack doesn't officially support Apple Silicon. However, we can still
run salt install via homebrew and pointing to the `HOMEBREW_PREFIX`:

    sudo env HOMEBREW_PREFIX=/opt/homebrew salt-call --local state.highstate

### BBS-like Machine

If `machine_type = 'standalone'` in `pillar/custom/init.sls`, the machine will
be configured with the dependencies needed for the build system but without
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
