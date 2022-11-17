Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "skillfactory-test"
    vb.memory = "2048"
    vb.cpus = 2
	config.vm.hostname = "skillfactory-test"
	config.vm.network "forwarded_port", guest: 5432, host: 5432
	config.vm.network "public_network", ip: "192.168.100.170", netmask: "255.255.255.0", bridge: "Intel(R) I211 Gigabit Network Connection", use_dhcp_assigned_default_route: true
	config.vm.provision "shell", path: "bootstrap.sh"
	end
 end
