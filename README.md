# Vagrant/Salt for a Linux BBS

## Requirements

* [Vagrant](https://vagrantup.com) 

## Quick Start

1. Install Vagrant

2. To start the VM from the Bioconductor Vagrant repository

    ```
    vagrant up
    ```

3. To access the VM

    ```
    vagrant ssh
    ```

4. Before running any builds, you should change the configuration for your
   system. For example, to configure the 3.14 `bioc` software builds,
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
    #export BBS_OUTGOING_MAP="source:nebbiolo2/buildsrc" # leave only nebbiolo2 and comment out
    export BBS_FINAL_REPO="file://home/biocpush/PACKAGES/$BBS_BIOC_VERSION/bioc"
    
    # Control generation of the report:
    export BBS_REPORT_NODES="nebbiolo2" # leave only nebbiolo2
    export BBS_REPORT_PATH="$BBS_CENTRAL_RDIR/report"
    export BBS_REPORT_CSS="$BBS_HOME/$BBS_BIOC_VERSION/report.css"
    export BBS_REPORT_BGIMG="$BBS_HOME/images/DEVEL3b.png"
    export BBS_REPORT_JS="$BBS_HOME/$BBS_BIOC_VERSION/report.js"
    ```

5. Depending on the number of cores on your system, the build process requires
   a lot of resources and power. Change the CPU lines above for your machine.

6. Add the builds you wish to test to the `BBS/BBSreportutils.py` function
   `display_propagation_status` to prevent propagation.

7. You can `vagrant halt` to stop the VM or `vagrant destroy` to remove it.

### Running builds

After the VM is up and Salt has reached a high state, you can run the build;
however, you may want to edit file in the manifest for the build you want to run
so that only the packages you're interested will be build. You should include the
package and its dependencies. The following example assumes you're running 3.14
software builds.

    ```
    sudo su - biocbuild
    cd ~/bbs-3.14-bioc/manifest
    # edit ~/bbs-3.14-bioc/manifest/software.txt
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
    ```

See `https://github.com/Bioconductor/BBS/blob/master/Doc/Prepare-Ubuntu-20.04-HOWTO.md`
for more information on builds.

## Using Salt to Configure BBS Machine 

1. On the build machine, install the Salt minion

    ```
    sudo apt install salt-minion
    ```

2. Copy the files in `/saltstack` to `/srv`.

3. Copy ssh keys to `/srv/salt/common/files`.

4. Add key names and users to the pillar at `/srv/pillar/common/init.sls`. 

5. Configure additional settings in the pillar. Some states for specific Bioc
   packages are defined in the pillar. If they are no longer needed, they
   maybe set to False.

6. Run salt, with debug or testing (`test=True`) if desired:

    ```
    sudo salt-call --local state.highstate -l debug
    ```

7. Configure the BBS configuration files.

## Notes

- When using the VM, you can access the `biocbuild` user with `sudo su - biocbuild`.
  It's important to use the `-` to preserve environmental variables.
- You may want to increase the memory in the Vagrantfile if you plan to build
  several packages.
- Still having issues installing Bioc package `MMAPPR2`.
