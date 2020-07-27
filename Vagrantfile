# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "bootstrap.sh"

  # Kubernetes Master Server
  config.vm.define "kmaster" do |kmaster|
    kmaster.vm.box = "bento/ubuntu-18.04"
    kmaster.vm.hostname = "kmaster.example.com"
    kmaster.vm.network "private_network", ip: "172.42.42.100"
    kmaster.vm.synced_folder ".", "/vagrant" 
    kmaster.vm.network "forwarded_port", guest: 80, host: 32575
    for i in 8000..8001
    kmaster.vm.network "forwarded_port", guest:i, host: i
    end
    for i in 30000..32767
    kmaster.vm.network "forwarded_port", guest: i, host: i
    end
    kmaster.vm.provider "virtualbox" do |v|
      v.name = "kmaster"
      v.memory = 3048
      v.cpus = 6
    end
    kmaster.vm.provision "shell", path: "bootstrap_kmaster.sh"
  end

  NodeCount = 2

  # Kubernetes Worker Nodes
  (1..NodeCount).each do |i|
    config.vm.define "kworker#{i}" do |workernode|
      workernode.vm.box = "bento/ubuntu-18.04"
      workernode.vm.hostname = "kworker#{i}.example.com"
      workernode.vm.network "private_network", ip: "172.42.42.10#{i}"
      workernode.vm.provider "virtualbox" do |v|
        v.name = "kworker#{i}"
        v.memory = 3024
        v.cpus = 3
      end
      workernode.vm.provision "shell", path: "bootstrap_kworker.sh"
    end
  end

end
