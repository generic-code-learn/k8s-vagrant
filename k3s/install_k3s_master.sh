#!/bin/bash

set -euo pipefail

# # k3s主服务器内网地址
# export MY_SERVER_IP=172.21.0.11
# # k3s认证令牌，任意字符串
# export MY_TOKEN=943uoeitg4sh43589j38uj8irr439943oit
# # 内部网卡设备号，`ifconfig` 查看
# export MY_ETH_DEV=eth0
# # 自动获取本机IP，若无法获取请手动指定
# export MY_NODE_IP=`ip -o -4 addr list | grep $MY_ETH_DEV | awk '{print $4}' | cut -d/ -f1`
export iface=`ip -o -4 addr list | grep $ip | awk '{print $2}'`

# 更换源
sudo sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list
sudo sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
sudo sed -i 's/http:/https:/g' /etc/apt/sources.list

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

# 安装k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --token ${token} --node-ip ${ip} --advertise-address ${ip} --flannel-iface ${iface}" sh -
echo 'alias k='kubectl'' | sudo tee -a /root/.bashrc
