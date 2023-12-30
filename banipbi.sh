#!/bin/bash
echo -e "\033[46;33m---------------banipb---------------------------------\033[0m"
block_ip( )
## 上一分钟
t1=`date -d "-1 min" +%Y:%H:%M`
log=/var/log/auth.log

output_folder="/var/log/recoder123"  # 替换为实际文件夹路径

## 将上一分钟的日志截取出来定向输入到/tmp/tmp_last_min.log
egrep "$t1: [0-9]+" $log > /tmp/tmp_last_min.log

## 把IP访问次数超过20次的计算出来,写入到临时文件
awk '{print $1}' /tmp/tmp_last_min.log | sort -n | uniq -c| sort -n | awk '$1>20
{print $2}' > /tmp/bad_ip.list

## 看临时文件的行数
n=`wc -l /tmp/bad_ip.list|awk '{print $1}'`

## 如果临时文件行数为0,说明我们前面没有过滤出IP,否则就是过滤出来了
if [ $n -ne 0 ]
then
## 遍历所有满足条件的IP,然后封掉这些IP
for ip in `cat /tmp/bad_ip.list`
   do
     iptables -I INPUT -s $ip -j REJECT
   done
fi

## 获取当前时间中的分钟
t=`date +%M`

## 如果分钟为0或者30,也就是说每隔半小时会执行封IP的函数
## 先解封,再封
if [ $t == "00" ] || [ $t == "30" ]
then
block_ip
fi
mkdir -p "$output_folder"
  timestamp=$(date +"%Y%m%d%H%M%S")
  output_file="$output_folder/block_ip_log_$timestamp.txt"
  echo "Block IP Log for $timestamp" > "$output_file"
  cat /tmp/bad_ip.list >> "$output_file"
}

# 调用block_ip函数
block_ip