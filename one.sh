#!/bin/bash
echo -e "\033[46;33m---------------更新安装软件---------------------------------\033[0m"
# 更新包列表并升级已安装的软件包
apt-get update -y 
apt-get upgrade -y

# 安装 依赖
apt-get install vim -y
apt-get install touch -y
apt-get install cron -y 
apt-get install iptables -y 
apt-get install fail2ban -y 
apt-get install sudo -y 
apt-get install curl -y 
apt-get install socat -y 
apt-get install update -y 

echo -e "\033[46;33m--------------------------修改sshg---------------------------------\033[0m"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config_123backup #没测试
# 提示用户输入新的 SSH 端口号
read -p "请输入新的SSH端口号: " newport

# 使用 sed 命令修改 sshd_config 中的 Port 参数

# 使用 sed 命令插入新行
sed -i "2iPort $newport" /etc/ssh/sshd_config
sed -i '3iPubkeyAuthentication yes' /etc/ssh/sshd_config
sed -i '4iPasswordAuthentication no' /etc/ssh/sshd_config
sed -i '5iPermitRootLogin no' /etc/ssh/sshd_config
service ssh restart
echo "修改完成，请查看 vim /etc/ssh/sshd_config"


echo -e "\033[46;33m---------------v2安装---------------------------------\033[0m"
cd /usr/local/etc/v2ray
v1="https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh"
v2="https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-dat-release.sh"
curl -O $v1
curl -O $v2
bash install-release.sh
bash install-dat-release.sh

echo -e "\033[46;33m---------------更新安装jason---------------------------------\033[0m"
cd /usr/local/etc/v2ray
touch config.json
read -p "请输入V2UUID: " id
jsoncont='{
  "inbounds": [
    {
      "port": 443, // 服务器端口
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "'"$id"'", // V2ray客户端UUID 
            "alterId": 0
          }
        ]
      },
      "streamSettings": {
        "network": "ws", // TCP或WS
        "security": "tls", // security 要设置为 tls 才会启用 TLS
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/rowte/ea.crt", // 证书文件路径
              "keyFile": "/etc/rowte/ea.key" // 密钥文件路径
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}'
echo "$jsoncont" > /usr/local/etc/v2ray/config.json

echo "JSON file created successfully: vim /usr/local/etc/v2ray/config.json"
echo -e "\033[46;33m--------------------------安装域名依赖debian系统---------------------------------\033[0m"
apt-get update -y 
apt-get install socat  -y 
apt-get update -y 
mkdir /etc/rowte
cd /etc/rowte
# 下载并安装 acme.sh
curl https://get.acme.sh | sh
source ~/.bashrc
export PATH="$HOME/.acme.sh:$PATH"
echo -e "\033[46;33m----------------申请证书---------------------------------\033[0m"
acme.sh --version
acme.sh --upgrade
cd /etc/rowte
touch ea.crt
touch ea.key

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

echo -e " \033[46;33m----------------BSR---------------------------------\033[0m"
#修改系统变量
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
#保存生效
sysctl -p

echo -e "\033[46;33m--------------------------iptables规则---------------------------------\033[0m"
read -p "请输入ss" port
read -p "输入前三位ip" port1 
read -p "输入3-6位ip" port2 
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -s $port1.$port2.0.0/16 -m state --state NEW --dport $port -j ACCEPT
iptables -A INPUT -p tcp --dport $port -j DROP
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 13 -s 0/0 -j DROP
iptables -A INPUT -p icmp --icmp-type 8 -s 0/0 -j  DROP 
#禁止ping
iptables -A INPUT -p icmp --icmp-type 11 -s 0/0 -j  DROP 
#禁止traceroute 
iptables -A INPUT -m state --state INVALID -j DROP
#删除 iptables -D INPUT 3  
iptables -A INPUT -p tcp -s 120.239.0.0/16 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 120.231.0.0/16 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 120.234.0.0/16 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 120.235.0.0/16 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 120.236.0.0/16 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 120.233.0.0/16 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 120.232.0.0/16 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 173.245.48.0/20 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 103.21.244.0/22 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 103.22.200.0/22 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 103.31.4.0/22 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 141.101.64.0/18 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 108.162.192.0/18 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 190.93.240.0/20 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 188.114.96.0/20 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 197.234.240.0/22 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 198.41.128.0/17 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 162.158.0.0/15 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 104.16.0.0/12 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 172.64.0.0/13 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -s 131.0.72.0/22 -m limit --limit 25/minute --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d 112.94.0.0/16 -m limit --limit 25/min --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d 112.96.0.0/16 -m limit --limit 25/min --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d 112.97.0.0/16 -m limit --limit 25/min --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d 27.47.0.0/16 -m limit --limit 25/min --limit-burst 100 -m state --state NEW,ESTABLISHED -m multiport --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp -d $port1.$port2.0.0/16 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d 120.239.0.0/16 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d 120.231.0.0/16 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d 120.234.0.0/16 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d 120.235.0.0/16 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d 120.236.0.0/16 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d 120.232.0.0/16 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d 120.233.0.0/16 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
ip6tables -P OUTPUT DROP
ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
iptables-save
ip6tables-save
iptables-save > /etc/iptables.conf
ip6tables-save > /etc/ip6tables.conf
echo -e "\033[46;33m--------------------------编辑该自启动配置文件，内容为启动网络时恢复iptables配置---------------------------------\033[0m"
touch /etc/network/if-pre-up.d/iptables
echo "#!/bin/bash" >> /etc/network/if-pre-up.d/iptables
echo "/sbin/iptables-restore < /etc/iptables.conf" >> /etc/network/if-pre-up.d/iptables
echo "/sbin/ip6tables-restore < /etc/ip6tables.conf" >> /etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables #授权执行


