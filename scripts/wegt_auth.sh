#!/bin/sh
# ====================================================
# 桂电 DrCOM OpenWrt 自动认证脚本 (wget 版)
# 说明：本脚本用于检测网络状态，并在断网时自动向认证服务器
#       发起带有特殊字符安全编码的认证请求。
# ====================================================

# ========== 用户配置区 ==========
STUDENT_ID="你的学号"
PASSWORD="你的密码"          # 密码可包含任意特殊字符，无需手动转义
OPERATOR=""                  # 校园网留空，联通: unicom，移动: cmcc，电信: telecom
R3="0"                       # 校园网: 0，联通: 2，移动: 3，电信: 1
AUTH_SERVER="10.0.1.5"       # 认证服务器 IP 地址
# ================================

# ====================================================
# 核心函数：URL 编码转换 (URL Encode)
# 功能：将字符串中的特殊字符（如 @, #, &, 空格 等）转换为十六进制的 %XX 格式，
#       以防止这些字符破坏 HTTP 请求的 URL 结构。
# ====================================================
urlencode() {
    local string="${1}"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for (( pos=0 ; pos<strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) 
                # 如果是安全字符，则直接保留
                o="${c}" 
                ;;
            * ) 
                # 如果是特殊字符，使用 printf 转换为 %XX 格式 (如 @ 变 %40)
                o=$(printf '%%%02x' "'$c") 
                ;;
        esac
        encoded="${encoded}${o}"
    done
    echo "${encoded}"
}

# 1. 对学号和密码进行安全的 URL 编码处理
STUDENT_ID_ENC=$(urlencode "$STUDENT_ID")
PASSWORD_ENC=$(urlencode "$PASSWORD")

# 2. 构造拼接的账号参数 (学号%40运营商)
if [ -n "$OPERATOR" ]; then
    USER_ENC="${STUDENT_ID_ENC}%40${OPERATOR}"
else
    USER_ENC="${STUDENT_ID_ENC}"
fi

# 3. 构造完整的认证 URL
AUTH_URL="http://${AUTH_SERVER}/drcom/login?callback=dr1003&DDDDD=${USER_ENC}&upass=${PASSWORD_ENC}&0MKKey=123456&R1=0&R3=${R3}&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn"

# 4. 核心逻辑：检测外网连通性
# 尝试 ping 阿里云 DNS (223.5.5.5)，超时时间设为 3 秒。
# 如果 ping 不通，说明网络断开或认证失效，触发认证逻辑。
if ! ping -c 1 -W 3 223.5.5.5 > /dev/null 2>&1; then
    # 使用 wget 发起 GET 请求，-O- 表示将响应输出到标准输出，然后丢弃
    wget -O- "$AUTH_URL" > /dev/null 2>&1
    fi
