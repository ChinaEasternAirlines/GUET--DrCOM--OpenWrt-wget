#!/bin/sh
# 桂林电子科技大学联通宽带 Dr.COM 自动认证脚本
# 适用：OpenWrt，使用 wget 实现
# 作者：飞向南北与西东
# 日期：2026-10-17

# ========== 用户配置 ==========
STUDENT_ID="你的学号"
PASSWORD="你的密码"          # 注意密码转义!Eg.密码中的 @ 转义为 %40
OPERATOR="unicom"            # 联通 unicom，移动 cmcc，电信 telecom，校园网留空
R3="2"                       # 联通 2，移动 3，电信 1，校园网 0
AUTH_SERVER="10.0.1.5"       # 认证服务器地址
# =============================

# 构造认证 URL
AUTH_URL="http://${AUTH_SERVER}/drcom/login?callback=dr1003&DDDDD=${STUDENT_ID}%40${OPERATOR}&upass=${PASSWORD_ENC}&0MKKey=123456&R1=0&R3=${R3}&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn"

# 检查外网是否通，不通则认证
if ! ping -c 1 -W 3 223.5.5.5 > /dev/null 2>&1; then
    wget -O- "$AUTH_URL" > /dev/null 2>&1
fi
