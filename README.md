# Vagrant/Salt for a Linux BBS

## Requirements

* [Vagrant](https://vagrantup.com)

## Quick Start

1. Install Vagrant

2. Configure the settings in the `Vagrantfile` for your system.

3. Configure the settings in `saltstack/pillar/common/init.sls`.

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
   your system.

   ```
   sudo su - biocbuild
   cd /home/biocbuild/BBS
   ```

   Edit the configuration files for the version of Bioconductor you will
   set up. For example, to configure the 3.14 `bioc` software builds,
   edit the following lines in `BBS/3.14/bioc/nebbiolo2/config.sh`:

    ```
    export BBS_DEBUG="0"

    export BBS_NODE_HOSTNAME="nebbiolo2"
    export BBS_USER="biocbuild"
    export BBS_WORK_TOPDIR="/home/biocbuild/bbs-3.14-bioc"
    export BBS_R_HOME="$BBS_WORK_TOPDIR/R"
    export BBS_NB_CPU=8        # change to a reasonable value for your system
    export BBS_CHECK_NB_CPU=8  # change to a reasonable value for your system
    
    export BBS_CENTRAL_RHOST="localhost"
    export BBS_CENTRAL_ROOT_URL="http://$BBS_CENTRAL_RHOST"
    ...
    # Control propagation:
    #export BBS_OUTGOING_MAP="source:nebbiolo2/buildsrc" # comment out
    export BBS_FINAL_REPO="file://home/biocpush/PACKAGES/$BBS_BIOC_VERSION/bioc"
    
    # Control generation of the report:
    export BBS_REPORT_NODES="nebbiolo2" # leave only nebbiolo2
    export BBS_REPORT_PATH="$BBS_CENTRAL_RDIR/report"
    export BBS_REPORT_CSS="$BBS_HOME/$BBS_BIOC_VERSION/report.css"
    export BBS_REPORT_BGIMG="$BBS_HOME/images/DEVEL3b.png"
    export BBS_REPORT_JS="$BBS_HOME/$BBS_BIOC_VERSION/report.js"
    ```

   Depending on the number of cores on your system, the build process requires
   a lot of resources and power. Change the CPU lines above for your machine.
   Comment out the `BBS_OUTGOING_MAP` as we will not perform propagation.

7. Add the builds you wish to test to the `BBS/BBSreportutils.py` function
   `display_propagation_status` to prevent propagation.

8. You can `vagrant halt` to stop the VM or `vagrant destroy` to remove it.

### Running builds

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

## Using Salt to Configure a Build Machine

1. On the build machine, install the Salt minion and clone the repository:

    ```
    sudo apt install salt-minion
    ```

2. Copy `saltstack/minion.d/minion` to `/etc/salt/minion`.

3. Copy the files in `/saltstack` to `/srv`.

4. Copy ssh keys to `/srv/salt/common/files`.

5. Add key names and users to the pillar at `/srv/pillar/common/init.sls`.

6. Configure additional settings in the pillar. Some states for specific Bioc
   packages are defined in the pillar. If they are no longer needed, they
   maybe set to `False`.

7. Run salt, with debug or testing (`test=True`) if desired:

    ```
    sudo salt-call --local state.highstate -l debug
    ```

8. Configure the `BBS` configuration files.

9. Uncomment the desired builds in the crontab as `biocbuild`.

## Notes

- When using the VM, access the `biocbuild` user with `sudo su - biocbuild`
  to preserve environmental variables.
- The prerun script will attempt to update the `manifest`, so you should
  update your `manifest` repository first then edit the file corresponding to
  the build you plan run.
- You may want to increase the memory in the Vagrantfile if you plan to build
  several packages.
- Still having issues installing Bioc package `MMAPPR2`.
