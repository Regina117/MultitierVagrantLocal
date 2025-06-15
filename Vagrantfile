VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/focal64"

  machines = [
    { name: "frontend", ip: "192.168.56.10", script: "nginx.sh" },
    { name: "backend", ip: "192.168.56.11", script: "tomcat.sh" },
    { name: "db", ip: "192.168.56.12", script: "mysql.sh" },
    { name: "cache", ip: "192.168.56.13", script: "redis.sh" },
    { name: "broker", ip: "192.168.56.14", script: "rabbitmq.sh" }
  ]

  machines.each do |machine|
    config.vm.define machine[:name] do |node|
      node.vm.hostname = "#{machine[:name]}.local"
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.provision "shell", path: "scripts/#{machine[:script]}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = 1536
        vb.cpus = 1
      end
    end
  end
end
