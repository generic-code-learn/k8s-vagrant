#!/bin/bash

set -euo pipefail

source /vagrant/0-common_install.sh

# 初始化 Kubernetes 主节点
sudo kubeadm init --apiserver-advertise-address=${ip} --pod-network-cidr=10.244.0.0/16 --service-cidr=10.250.0.0/16

# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf
echo 'export KUBECONFIG=/etc/kubernetes/admin.conf' | sudo tee -a /root/.bashrc
echo 'alias k='kubectl'' | sudo tee -a /root/.bashrc

# 写入join
sudo kubeadm token create --print-join-command | sudo tee /vagrant/kubeadm_join

# 安装网络插件
# sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml