#! /bin/bash
export guser=vagrant

# //NOTE: exec script on master as #source <script.sh> $1

#--------------------------------------------------------------------------------------------------------#

# //update packages
for u in update upgrade; do sudo apt-get $u -y; done && echo
sudo apt-get --purge autoremove -y && echo

# //as root set static hostname on master
sudo hostnamectl set-hostname --static $1 && echo

# //"$(hostname -I)" master //add this in /etc/hosts as:
sudo tee --append --ignore-interrupts 
  - name: Append entry to /etc/hosts
      lineinfile:
        path: /etc/hosts
        line: "{{ ansible_facts['default_ipv4']['address'] }} {{ ansible_hostname }}"
        state: present/etc/hosts <<<"$(hostname -I)   "$1"" && echo

# //check swap status & off it
free -h && sudo swapon -s && sudo swapoff -a && echo

# //comment it also in /etc/fstab
sudo sed -i '12s/^\([^#]\)/#\1/g' -i /etc/fstab #comment specified line
# //sudo sed -i '12s/^#//g' /etc/fstab              #uncomment specified line

sed -i '/\/swap.img\|\/swapfile/ s/^/# /' /etc/fstab  #comment
sed -i '/\/swap.img\|\/swapfile/ s/^# //' /etc/fstab  #uncomment

#---------------------------------------------------------------------------------------------------------#

# //install docker as:
# source /home/$guser/docker-setup.sh && echo
sudo chmod 666 /var/run/docker.sock

# //sudo systemctl reboot //it reboot server

# //Set Forwarding IPv4 and letting iptables see bridged traffic as:
sudo mkdir -p /etc/modules-load.d && sudo touch /etc/modules-load.d/k8s.conf
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# //sysctl params required by setup, params persist across reboots
sudo mkdir -p /etc/sysctl.d && sudo touch /etc/sysctl.d/k8s.conf
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# //Apply sysctl params without reboot
sudo sysctl --system && echo
lsmod | grep -e br_netfilter -e overlay && echo
sudo sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward && echo

sudo modprobe br_netfilter
sudo sysctl -p /etc/sysctl.conf

# //enable/diable apparmor
# sudo systemctl enable --now apparmor.service && echo

# //NOW: Follow kubelet kubeadm kubectl installetion steps as:
for u in update upgrade; do sudo apt-get $u -y; done && echo
sudo apt-get --purge autoremove -y && echo
sudo apt-get install -y apt-transport-https ca-certificates curl && echo

# # //Add gcp signing key:
curl -L -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg add -
# curl -L -s https://dl.k8s.io/apt/doc/apt-key.gpg | sudo apt-key --keyring /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg add -

# # //Add k8s apt repo as:
echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

for u in update upgrade; do sudo apt-get $u -y; done && echo

sudo apt-get install -y kubelet kubeadm kubectl && echo
sudo apt-mark hold kubelet kubeadm kubectl && echo

# # //Configure Cgroup Driver as: add json data in
sudo mkdir -p /etc/docker && sudo touch /etc/docker/daemon.json
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
   "storage-driver": "overlay2"
}
EOF

sudo systemctl restart docker.service containerd.service && docker info && echo

# //Set kubectl shell autocomplition
echo -e "\nsource <(kubectl completion bash)" >>/home/$guser/.bashrc
echo -e "\nsource <(kubeadm completion bash)\n" >>/home/$guser/.bashrc
echo -e "\nsource <(kubectl completion zsh)" >>/home/$guser/.zshrc
echo -e "\nsource <(kubeadm completion zsh)\n" >>/home/$guser/.zshrc

# //exec $SHELL
# //Finally (Exec kubeadm-init.sh file)
