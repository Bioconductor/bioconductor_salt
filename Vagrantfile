# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.hostname = "nebbiolo2"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  config.vm.network "forwarded_port", guest: 81, host: 8081
  config.vm.network "forwarded_port", guest: 443, host: 4443

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder ".", "/BBS"
  config.vm.synced_folder "saltstack/salt", "/srv/salt"
  config.vm.synced_folder "saltstack/pillar", "/srv/pillar"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    #vb.gui = true
  
    # Customize the amount of memory on the VM:
    vb.memory = "4096"
  end

  # Copy your public key and authorized_keys files to the vagrant
  config.vm.provision "file", source: "~/.ssh/id_rsa", destination: "/srv/salt/common/files/id_rsa"
  config.vm.provision "file", source: "~/.ssh/authorized_keys", destination: "/srv/salt/common/files/authorized_keys"
  
  config.vm.provision :salt do |salt|
    salt.masterless = true
    salt.minion_config = "saltstack/minion.d/minion.conf"
    salt.run_highstate = true
  end

end
