#! /bin/bash

# //Exec & reboot, below on local-kvm-worker if its snap-vm, to get new-ip
# sudo truncate -s 0 /etc/machine-id && sudo rm /var/lib/dbus/machine-id
# sudo ln -s /var/lib/dbus/machine-id /etc/machine-id

# //Allow ports on worker
sudo ufw status && echo
# echo -e y | sudo ufw enable
# for ports in 22 10250 30000:32767; do sudo ufw allow $ports/tcp; done
# sudo ufw reload && echo

# //Open Calico addon N/w Req Port.on M/w node
# sudo ufw allow 179/tcp (skip it)

# //check swap status & off it
free -h && sudo swapon -s && sudo swapoff -a && echo

# //comment it also in /etc/fstab
sudo sed -i '12s/^\([^#]\)/#\1/g' -i /etc/fstab #comment specified line
# //sudo sed -i '12s/^#//g' /etc/fstab              #uncomment specified line

# //finally Exec join command on worker node
sudo kubeadm reset -f && echo
# sudo kubeadm reset -f --cri-socket=unix:///var/run/containerd/containerd.sock && echo

# //reset CNI
sudo rm -rf /etc/cni/net.d

# //reset iptables (skip it)
# //sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

# reset your system's IPVS tables
sudo apt install ipvsadm network-manager -y && echo
# sudo ipvsadm -C
nmcli device

# kubeadm join 192.168.122.189:6443 --token zj4zbn.y9k4xubzybegysl8 \
#     --discovery-token-ca-cert-hash sha256:cffa2723bfde3d5253edd39342b73e8ee9cb4e3e761afbd5c26b4bbe8936502c

# kubeadm join echo $(ip addr list enp1s0 | grep "inet " | cut -d' ' -f6 | cut -d/ -f1):6443 --token \
#     --discovery-token-ca-cert-hash sha256:\
# echo $(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')

# //sudo systemctl reboot // manditory
