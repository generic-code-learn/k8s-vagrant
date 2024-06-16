#!/bin/bash

set -euo pipefail

source /vagrant/0-common_install.sh

# 执行join
sudo bash /vagrant/kubeadm_join

