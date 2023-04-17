# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-22.04"

  # Global Libvirt provider configuration
  config.vm.provider :libvirt do |libvirt|
    libvirt.memory = "4096"
    libvirt.cpus = 2
    libvirt.storage :file, size: '20G'
    libvirt.driver = "kvm"
  end

  # Array of VM hostnames
  vms = ["master", "worker"]

  # Create VMs using loop
  vms.each do |hostname|
    config.vm.define hostname do |vm_config|
      vm_config.vm.hostname = hostname
    end
  end

# Run Ansible from the Vagrant Host
  config.vm.provision "ansible" do |ansible|
    # become = yes
    # become_user = ubuntu
    ansible.limit = "all"
    ansible.playbook = "./mainplay.yml"
    # ansible.inventory_path = "./my-inventory"
    # default ansible_host=192.168.111.222
    # ansible.galaxy_role_file = "requirements.yml"
    # tags = db
    # ansible.verbose = "v"
    ansible.compatibility_mode = "2.0"

    ansible.raw_arguments  = [
      "--connection=paramiko"
      # "--private-key=/home/.../.vagrant/machines/.../private_key"
    ]

    # ansible.host_vars = {
    #   "host1" => {"http_port" => 80,"maxRequestsPerChild" => 808},
    #   "host2" => {"http_port" => 303,"maxRequestsPerChild" => 909}
    # }

    # ansible.groups = {
    #   "group1" => ["machine1"],
    #   "group2" => ["machine2"],
    #   "group3" => ["machine[1:2]"],
    #   "group4" => ["other_node-[a:d]"], # silly group definition
    #   "all_groups:children" => ["group1", "group2"],
    #   "group1:vars" => {"variable1" => 9,"variable2" => "example"}
    # }

    # ansible.extra_vars = {
    #   ntp_server: "pool.ntp.org",
    #   nginx: {
    #     port: 8008,
    #     workers: 4
    #   }
    # }

  end 

  # config.vm.provision "shell", inline: <<-SHELL

  #   # Clone the bootstrap repository
  #   git clone https://github.com/Surajwaghmare35/k8s-bootstrap.git

  #   # Provisioning script
  #   if [ "$(hostname)" = "master" ]; then
  #     source /home/vagrant/k8s-bootstrap/docker-setup.sh
  #     source /home/vagrant/k8s-bootstrap/kubeadm-k8s-setup.sh master
  #     source /home/vagrant/k8s-bootstrap/kubeadm-master-init.sh
  #   elif [ "$(hostname)" = "worker" ]; then
  #     source /home/vagrant/k8s-bootstrap/docker-setup.sh
  #     source /home/vagrant/k8s-bootstrap/kubeadm-k8s-setup.sh worker
  #     source /home/vagrant/k8s-bootstrap/k8s-worker-up.sh
  #   fi
  # SHELL

  config.trigger.after :up,
    name: "Do Vagrant ssh vm, execute below to set zsh & run: sudo apt-get upgrade -y &&  omz update",
    info: 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
end
