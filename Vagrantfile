# -*- mode: ruby -*-
# vi: set ft=ruby :

MASTER_NODES_COUNT  = 1
CLIENT_NODES_COUNT  = 2
NODE_CPUS           = 2  # vCPUs per Cloud Node
NODE_MEMORY         = 2048  # 4GB plus ~200MB headroom

def packages_debianoid(user)
  return <<-EOF
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get -y install python-simplejson
  EOF
end

Vagrant.configure("2") do |config|

  config.ssh.insert_key = false
  config.ssh.private_key_path = ["~/.ssh/id_rsa", "~/.vagrant.d/insecure_private_key"]
  config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"
  config.vm.provision "packages debianoid", :type => :shell, :inline => packages_debianoid("vagrant")

  (1.. MASTER_NODES_COUNT).each do |i|
    config.vm.define "manager#{"%02d" % i}" do |manager|
      manager.vm.hostname = "manager#{"%02d" % i}"
      manager.vm.box = "generic/debian10"
      manager.vm.provider :libvirt do |domain|
        domain.default_prefix = ""
        domain.cpus = NODE_CPUS
        domain.memory = NODE_MEMORY
        end
      end
    end

  (1.. CLIENT_NODES_COUNT).each do |i|
  config.vm.define "worker#{"%02d" % i}" do |worker|
    worker.vm.hostname = "worker#{"%02d" % i}"
    worker.vm.box = "generic/debian10"
    worker.vm.provider :libvirt do |domain|
      domain.default_prefix = ""
      domain.cpus = NODE_CPUS
      domain.memory = NODE_MEMORY
      end
    end
  end
end
