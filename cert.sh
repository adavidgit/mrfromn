#!/bin/bash
echo -e "\033[46;33m--------------------------换证书---------------------------------\033[0m"
echo -e "\033[46;33m--------------------------安装域名依赖debian系统---------------------------------\033[0m"
apt-get update -y 
rm /etc/rowte/ea.crt
rm /etc/rowte/ea.key
cd /etc/rowte
# 下载并安装 acme.sh
curl https://get.acme.sh | sh
source ~/.bashrc
export PATH="$HOME/.acme.sh:$PATH"
echo -e "\033[46;33m----------------申请证书---------------------------------\033[0m"
acme.sh --version
acme.sh --upgrade
cd /etc/rowte
touch /etc/rowte/ea.crt
touch /etc/rowte/ea.key
read -p "Enter 域名: " doname
export doname
acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --register-account -m ashleybrowngfgh@gmail.com
~/.acme.sh/acme.sh --issue -d $doname --standalone -k ec-256
echo "Installation complete."
echo -e "\033[46;33m----------------安装证书---------------------------------\033[0m"
~/.acme.sh/acme.sh --installcert -d $doname --fullchainpath /etc/rowte/ea.crt --keypath /etc/rowte/ea.key --ecc
chmod 644 /etc/rowte/ea.key
acme.sh --upgrade --auto-upgrade
systemctl restart v2ray
systemctl status v2ray
systemctl enable v2ray