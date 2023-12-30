#!/bin/bash
echo -e "\033[46;33m---------------banipop---------------------------------\033[0m"

# 设置登录失败次数的阈值
threshold=50
log_file1="/var/log/badip.list1"
log_file2="/var/log/badip.list2"

# 检查日志文件是否存在，不存在则创建
touch "$log_file1"
touch "$log_file2"

# 获取当前分钟的日志并提取登录失败的 IP 地址
failed_ips=$(grep "Failed password" /var/log/auth.log | awk -v threshold="$threshold" '{print $(NF-3)}' | sort | uniq -c | awk -v threshold="$threshold" '$1 > threshold {print $2}')

# 将失败的 IP 地址追加到 /var/log/badip.list1 文件中
echo "$failed_ips" >> /var/log/badip.list1

# 检查是否有超过阈值的 IP 地址
if [ -n "$failed_ips" ]; then
  echo "以下 IP 地址的登录失败次数超过每分钟 $threshold 次："
  echo "$failed_ips"

  # 遍历失败的 IP 地址，并添加到 iptables 规则中
  for ip in $failed_ips; do
    iptables -A INPUT -s "$ip" -j DROP
    echo "已禁止 IP 地址 $ip 访问。"
    echo "$ip" >> /var/log/badip.list2
  done

  # 保存 iptables 规则
  service iptables save
  echo "iptables 规则已保存。"
else
  echo "没有 IP 地址的登录失败次数超过每分钟 $threshold 次。"
fi



==============
awk '/Failed password/ {print}' /var/log/auth.log

grep "Failed password" /var/log/auth.log | awk -v threshold="$threshold" '{print $(NF-3)}' | sort | uniq -c | awk -v threshold="$threshold" '$1 > threshold {print $2}'
