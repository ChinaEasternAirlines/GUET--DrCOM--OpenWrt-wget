#!/bin/sh
# ====================================================
# 桂电 DrCOM OpenWrt 自动认证 - 一键安装脚本
# ====================================================

# 1. 检查是否为 root 用户
if [ "$(id -u)" != "0" ]; then
    echo "错误：请使用 root 用户运行此脚本！"
    exit 1
fi

echo "===================================================="
echo "   桂林电子科技大学 Dr.COM 自动认证一键安装脚本"
echo "===================================================="
echo ""

# 2. 交互式获取用户信息
read -p "请输入你的学号 (例: 2600310120): " STUDENT_ID
if [ -z "$STUDENT_ID" ]; then
    echo "错误：学号不能为空！"
    exit 1
fi

# 隐藏密码输入
stty -echo
read -p "请输入你的校园网密码: " PASSWORD
stty echo
echo ""
if [ -z "$PASSWORD" ]; then
    echo "错误：密码不能为空！"
    exit 1
fi

echo "请选择你的运营商:"
echo "  1) 联通 (Unicom)"
echo "  2) 移动 (CMCC)"
echo "  3) 电信 (Telecom)"
echo "  4) 校园网 (Campus)"
read -p "请输入对应数字 [1-4] (默认 1): " ISP_CHOICE

# 根据选择设置运营商参数
case "$ISP_CHOICE" in
    2) OPERATOR="cmcc"; R3="3" ;;
    3) OPERATOR="telecom"; R3="1" ;;
    4) OPERATOR=""; R3="0" ;;
    *) OPERATOR="unicom"; R3="2" ;; # 默认联通
esac

AUTH_SERVER="10.0.1.5" # 桂电认证服务器地址

echo ""
echo "正在生成自动认证脚本..."
# 3. 生成核心认证脚本 /usr/bin/drcom_login.sh
cat > /usr/bin/drcom_login.sh << EOF
#!/bin/sh
# ====================================================
# 本脚本由 install.sh 自动生成
# 学号: $STUDENT_ID  | 运营商: \${OPERATOR:-校园网}
# ====================================================

STUDENT_ID="$STUDENT_ID"
PASSWORD="$PASSWORD"
OPERATOR="$OPERATOR"
R3="$R3"
AUTH_SERVER="$AUTH_SERVER"

# 处理用户名后缀
if [ -n "\$OPERATOR" ]; then
    USER="\${STUDENT_ID}%40\${OPERATOR}"
else
    USER="\${STUDENT_ID}"
fi

# 密码转义：将 @ 替换为 %40
PASSWORD_ENC=\$(echo "\$PASSWORD" | sed 's/@/%40/g')

# 构造认证 URL
AUTH_URL="http://\${AUTH_SERVER}/drcom/login?callback=dr1003&DDDDD=\${USER}&upass=\${PASSWORD_ENC}&0MKKey=123456&R1=0&R3=\${R3}&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn"

# 检查外网是否通，不通则认证
if ! ping -c 1 -W 3 223.5.5.5 > /dev/null 2>&1; then
    wget -O- "\$AUTH_URL" > /dev/null 2>&1
fi
EOF

# 赋予执行权限
chmod +x /usr/bin/drcom_login.sh
echo "核心脚本已生成: /usr/bin/drcom_login.sh"

# 4. 配置定时任务 (Crontab)
echo "正在配置定时任务 (每分钟检测一次)..."
CRON_JOB="* * * * * /usr/bin/drcom_login.sh > /dev/null 2>&1"

# 检查是否已经存在定时任务，避免重复添加
if crontab -l 2>/dev/null | grep -Fq "/usr/bin/drcom_login.sh"; then
    echo "定时任务已存在，跳过添加。"
else
    # 获取当前 crontab 并追加新任务
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "定时任务已添加！"
fi

# 5. 立即执行一次认证测试
echo ""
echo "正在尝试立即执行一次认证..."
/usr/bin/drcom_login.sh

# 6. 测试网络连通性
echo "正在测试外网连接 (ping 223.5.5.5)..."
if ping -c 3 223.5.5.5 > /dev/null 2>&1; then
    echo "认证成功，外网连接正常！"
else
    echo "认证可能失败或外网不通，请检查账号密码或稍后重试。"
fi

echo "===================================================="
echo "安装完成！"
echo "你可以随时修改配置: vi /usr/bin/drcom_login.sh"
echo "===================================================="
