#!/bin/bash

# # k3s主服务器内网地址
# export MY_SERVER_IP=172.21.0.11
# # k3s认证令牌，任意字符串
# export MY_TOKEN=943uoeitg4sh43589j38uj8irr439943oit
# # 内部网卡设备号，`ifconfig` 查看
# export MY_ETH_DEV=eth0
# # 自动获取本机IP，若无法获取请手动指定
# export MY_NODE_IP=`ip -o -4 addr list | grep $MY_ETH_DEV | awk '{print $4}' | cut -d/ -f1`

# 安装k3s
export master_ip=$(cat /vagrant/k3s_master_ip)
export token=$(cat /vagrant/k3s_master_token)
export iface=$(cat /vagrant/k3s_master_ip)

wget -qO- https://get.k3s.io | sh -s - agent \
    --server https://${master_ip}:6443 \
    --token ${token} \
    --node-ip ${ip} \
    --flannel-iface ${iface}