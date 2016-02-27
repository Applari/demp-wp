# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "phusion/ubuntu-14.04-amd64" # vmware
  #config.vm.box = "parallels/boot2docker"

  config.vm.box_check_update = false

  config.vm.hostname = "docker-host"
  config.vm.network :forwarded_port, guest: 80, host: 80
  config.vm.network "public_network"
  #config.vm.network "public_network", ip: "192.168.1.200"

  #config.vm.network "public_network", ip: "192.168.33.10"
  #config.vm.synced_folder 'code/', '/usr/share/nginx/www', type: "nfs" , mount_options: ["nolock", "vers=3", "udp"], id: "nfs-sync"
  config.vm.synced_folder 'code/', '/usr/share/nginx/www', type: "nfs" 
  #config.vm.synced_folder "/Users", "/Users", type: "nfs", mount_options: ["nolock", "vers=3", "udp"], id: "nfs-sync"

  Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  	config.vm.provision "docker" do |docker|
    	#docker.build_image "."
      d.build_dir = "."
    	docker.ports = ['80:80']
    	docker.name = 'docker-container'
  	end
   end
#  config.vm.provision :shell, path: "bootstrap.sh"

end