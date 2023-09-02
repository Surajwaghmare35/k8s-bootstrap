#! /bin/bash
export guser=vagrant

# //NOTE: exec script as #source <script.sh>  //Ex: source kubeadm-k8s-setup.sh

# //Finally (Exec below all command from kubeadm-init.sh file)

# //allow below ports on master ufw as #sudo ufw allow rule/tcp & delete as #sudo ufw delete allow rule/tcp
sudo ufw status && echo
# echo -e y | sudo ufw enable
# for ports in 22 6443 2379:2380 10250 10259 10257; do sudo ufw allow $ports/tcp; done

# for ports in 6443 2379:2380 10250 10259 10257; do sudo ufw delete allow $ports/tcp; done

# sudo ufw reload && echo

sudo kubeadm reset -f && echo
# sudo kubeadm reset -f --cri-socket=unix:///var/run/containerd/containerd.sock && echo

# //reset CNI
sudo rm -rf /etc/cni/*

# //reset your system's IPVS tables
sudo apt-get install ipvsadm -y && echo
# sudo ipvsadm -C

docker system prune -f && echo

sudo kubeadm config images pull
# sudo kubeadm config images pull --cri-socket=unix:///var/run/containerd/containerd.sock

echo
free -h && sudo swapon -s && sudo swapoff -a && echo
sudo sed -i '12s/^\([^#]\)/#\1/g' -i /etc/fstab #comment specified line

# //For root/normal user
echo -e "export KUBECONFIG=/etc/kubernetes/admin.conf\n" >>/home/$guser/.bashrc
echo -e "export KUBECONFIG=/etc/kubernetes/admin.conf\n" >>/home/$guser/.zshrc
mkdir -p /home/$guser/.kube
sudo chown $(id -u):$(id -g) /home/$guser/.kube/config
sudo chown $guser:$guser /home/$guser/.kube/config

# # //Download Calico/Weave-Net for on-premises deployments as: (operator/manifest method)
wget -nc https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -P /home/$guser && echo
wget -nc https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml -P /home/$guser && echo
wget -nc https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml -P /home/$guser && echo

wget -nc https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml -P /home/$guser && echo

# # //Open calico N/w Req. Port
# # sudo ufw allow 179/tcp && echo
# # kubectl apply -f /home/$guser/calico.yaml && echo
# kubectl apply -f /home/$guser/tigera-operator.yaml && echo && kubectl apply -f /home/$guser/custom-resources.yaml && echo

# # //For Weave-Net N/w addon port
# # sudo ufw allow 6783/tcp && sudo ufw allow 6783,6784/udp && echo  (skip it)
# kubectl apply -f /home/$guser/weave-daemonset-k8s.yaml && echo

# //Initialize K8s Cluster
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 && echo
# sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/containerd/containerd.sock && echo

# sudo kubeadm init --apiserver-advertise-address=192.168.122.89 --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock && echo

# sudo kubeadm init && echo
sudo chmod 666 /var/run/docker.sock
sudo chmod 664 /etc/kubernetes/admin.conf
sudo cp -a /etc/kubernetes/admin.conf /home/$guser/.kube/config
# //without promt override.

# //Once kubeadm is setup kublet is auto enable
sudo systemctl enable --now kubelet.service

# # //sudo kubeadm upgrade plan

# watch kubectl get ns,deploy,po,svc,ing,ep,sc -A -o wide && echo

sudo apt-get install network-manager -y
nmcli device

# //sudo systemctl reboot // manditory
