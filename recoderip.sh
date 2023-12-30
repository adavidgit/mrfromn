#!/bin/bash
echo -e "\033[46;33m---------------记录ip---------------------------------\033[0m"


# 设置日志文件路径
log_file="/var/log/recoderL/logip123.txt"

# 检查日志文件是否存在，不存在则创建
touch "$log_file"

# 获取登录的 IP 地址
login_ips=$(grep "sshd.*Accepted password" /var/log/auth.log | awk '{print $(NF-3)}' | sort | uniq)

# 写入登录的 IP 地址到日志文件中
echo "[$(date)] 登录的 IP 地址：" >> "$log_file"
echo "$login_ips" >> "$log_file"
echo "" >> "$log_file"

echo "已将登录的 IP 地址写入到文件：$log_file"
