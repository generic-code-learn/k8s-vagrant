#!/bin/bash

set -euo pipefail

# 更换源
sudo sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# 加载内核模块
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# 配置网络内核
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# 关闭防火墙和iptables
sudo systemctl stop ufw && systemctl disable ufw && iptables -F
# 关闭selinux
sudo sed -i 's/enforcing/disabled/' /etc/selinux/config && setenforce 0
# 关闭swap
sudo swapoff -a
sudo sed -ri 's/.*swap.*/#&/' /etc/fstab

# 设置时区
sudo timedatectl set-timezone Asia/Shanghai
# 同步时时间
sudo apt update
sudo apt install -q -y ntp
sudo systemctl start ntp
sudo systemctl enable ntp

# 安装containerd
sudo apt install -y containerd
sudo mkdir -p /etc/containerd/
echo "$(sudo containerd config default)" | sudo tee /etc/containerd/config.toml > /dev/null
# 将 Cgroup 改为 Systemd
sudo sed -i '/SystemdCgroup/s/false/true/' /etc/containerd/config.toml
sudo systemctl enable --now containerd

sudo apt install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/apt/keyrings/
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt update
sudo apt install -q -y kubelet kubeadm
sudo systemctl enable kubelet
sudo apt-mark hold kubelet kubeadm

# 执行join
sudo bash /vagrant/kubeadm_join

