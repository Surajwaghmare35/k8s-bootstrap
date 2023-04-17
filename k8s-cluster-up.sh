#! /bin/bash

sudo chmod 666 /var/run/docker.sock
sudo chmod 644 /etc/kubernetes/admin.conf
kubectl drain master --delete-emptydir-data --force --ignore-daemonsets && echo
sudo kubeadm reset -f && echo

# //reset CNI
sudo rm -rf /etc/cni/net.d

# //reset iptables
# //sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

# //reset your system's IPVS tables
sudo apt install ipvsadm network-manager -y && echo
# sudo ipvsadm -C

sudo kubeadm init --pod-network-cidr=192.168.0.0/16 && echo
# sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --cri-socket=unix:///var/run/containerd/containerd.sock && echo
# //Follow above if use cri-dockerd

# sudo kubeadm init && echo
sudo chmod 666 /var/run/docker.sock
sudo chmod 644 /etc/kubernetes/admin.conf

# //Open Calico addon N/w Req Port.on M/w node
# sudo ufw allow 179/tcp (skip it)
# kubectl apply -f /home/vagrant/calico.yaml && echo
# kubectl apply -f /home/vagrant/tigera-operator.yaml && echo && kubectl apply -f /home/vagrant/custom-resources.yaml && echo

# //For Weave-Net N/w addon port
# sudo ufw allow 6783/tcp && sudo ufw allow 6783,6784/udp && echo  (skip it)
kubectl apply -f /home/vagrant/weave-daemonset-k8s.yaml && echo

watch kubectl get ns,deploy,po,svc,ing,ep,sc -A -o wide && echo

# //Uncomment to test nginc Ex on master
# kubectl describe nodes master | grep -i taint && echo
# kubectl taint node master node-role.kubernetes.io/control-plane:NoSchedule- && echo
# kubectl describe nodes master | grep -i taint && echo

watch kubectl get deploy,po,svc -A -o wide && echo
kubectl apply -f /home/vagrant/*/nginx-master.yml -f /home/vagrant/*/env-config.yml -f /home/vagrant/*/host-pv-pvc.yml && echo
watch kubectl get deploy,po,svc -A -o wide && echo

# //Set-up K8s dashboard
# kubectl describe nodes master | grep -i taint && echo
# kubectl taint node master node-role.kubernetes.io/control-plane:NoSchedule- && echo
# kubectl describe nodes master | grep -i taint && echo

kubectl apply -f /home/vagrant/*/dashboard-recommended.yaml -f /home/vagrant/*/dashboard-adminuser.yaml && echo
kubectl get svc -n kubernetes-dashboard kubernetes-dashboard && echo
kubectl edit svc -n kubernetes-dashboard kubernetes-dashboard && echo
# //as: NP/LB
kubectl taint node master node-role.kubernetes.io/control-plane:NoSchedule && echo
kubectl describe nodes master | grep -i taint && echo

# //Now we need to find the token we can use to log in. as:
kubectl -n kubernetes-dashboard create token admin-user >/home/vagrant/k8s-bootstrap/dashboard-user.token && echo
kubectl get svc -A && echo
cat /home/vagrant/k8s-bootstrap/dashboard-user.token && echo

# //using below we get hash of existing active tocken
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null |
    openssl dgst -sha256 -hex | sed 's/^.* //'
echo
nmcli device

# //sudo systemctl reboot // manditory
