#!/bin/bash
echo -e "\033[46;33m---------------更新安装jason---------------------------------\033[0m"
cp /usr/local/etc/v2ray/config.json /usr/local/etc/v2ray/config.json.backup_123 #没测试
cd /usr/local/etc/v2ray
rm /usr/local/etc/v2ray/config.json
touch config.json
read -p "请输入V2UUID: " id
read -p "请输入端口号: " por
read -p "请输入alterid: " altid

jsoncont='{
  "inbounds": [
    {
      "port": '$por', // 服务器端口
      "protocol": "vmess",    
      "settings": {
        "clients": [
          {
            "id": "'"$id"'", // V2ray客户端UUID 
            "alterId": '$altid'
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
systemctl restart v2ray
systemctl status v2ray
systemctl enable v2ray
echo "JSON file created successfully: vim /usr/local/etc/v2ray/config.json"