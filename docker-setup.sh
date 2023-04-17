#! /bin/bash
export guser=vagrant

# //NOTE: exec script as #source <script.sh>

# //this script work on ubuntu-18/20/22/23

#---------------------------------------------------------------------------------------------------------#

# //update packages
for u in update upgrade; do sudo apt-get $u -y; done && echo

sudo apt-get install zsh bash-completion -y 

sudo apt-get --purge autoremove -y && echo
sudo apt-get --purge autoremove docker docker.io containerd runc && echo
sudo apt-get install ca-certificates curl gnupg lsb-release && echo

# //Add Docker’s official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
ls -l /etc/apt/keyrings/ && echo

# //Add Docker’s official REPO:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
cat /etc/apt/sources.list.d/docker.list

for u in update upgrade; do sudo apt-get $u -y  ; done && echo

# //Install Docker Engine (containerd as cri include runc)
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y && clear
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y && echo
docker --version && echo && docker compose version

# //Install Containerd CNI-plugin
wget -nc https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz

# # //Install  nerdctl/crictl to intract with container (ex: crictl ps -a)
# VERSION="v1.26.0" # check latest version in /releases page
# wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
# sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
# rm -f crictl-$VERSION-linux-amd64.tar.gz

# cat <<EOF | sudo tee /etc/crictl.yaml
# runtime-endpoint: unix:///run/containerd/containerd.sock
# image-endpoint: unix:///run/containerd/containerd.sock
# timeout: 2
# debug: false
# pull-image-on-create: false
# EOF

# # //manually edit and change systemdCgroup to true
sudo mkdir -p /etc/containerd

# containerd config default | sudo tee /etc/containerd/config.toml
# sudo rm -rf /etc/containerd/config.toml

cat <<EOF | sudo tee -a /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
SystemdCgroup = true
EOF

# sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo sed -i 's/^disabled_plugins \=/\#disabled_plugins \=/g' /etc/containerd/config.toml
sudo systemctl daemon-reload && sudo systemctl restart docker containerd

# # //Verify that Docker Engine is installed correctly by pulling the nginx image.
# sudo crictl --version && sudo crictl version && sudo crictl pull nginx && sudo crictl images
sudo docker version && sudo docker compose version && sudo docker --version && sudo docker run hello-world

# # //Post-installation steps for Docker
sudo groupadd docker && sudo usermod -aG docker vagrant && newgrp docker

# //Set docker & compose permission
mkdir -p /home/$guser/.docker
sudo chown $guser:$guser /home/$guser/.docker -R
sudo chmod g+rwx /home/$guser/.docker -R

sudo chmod 666 /var/run/docker.sock
sudo chmod 666 /run/containerd/containerd.sock

docker run hello-world && echo && docker system prune -f

cat <<EOF | sudo tee /etc/default/locale
LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
EOF
sudo update-locale

# //Configure Docker to start on boot
sudo systemctl enable --now docker.service containerd.service && echo

# //setup editor
sudo apt-get install vim && sudo update-alternatives --set editor $(which vim).basic
sudo update-alternatives --set editor /usr/bin/vim.basic

# # //configure log-driver
sudo mkdir -p /etc/docker && sudo touch /etc/docker/daemon.json
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3" 
  },
   "storage-driver": "overlay2"
}
EOF
ls -l /etc/docker/daemon.json && echo

# //Restart Docker.
sudo systemctl daemon-reload && sudo systemctl restart docker.service containerd.service
sudo apt-get install net-tools -y && echo
sudo netstat -lntp | grep dockerd && echo

# //sudo systemctl reboot //it reboot server
