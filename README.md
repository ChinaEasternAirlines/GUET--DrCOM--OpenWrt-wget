**汉语** | [English](./README.en.md) | [日本語](./README.ja.md)
# 桂电 DrCOM OpenWrt wget 自动认证

桂林电子科技大学校园网 Dr.COM 认证的 OpenWrt 自动登录脚本，使用 wget 实现，支持断线重连。
> 以下内容由DeepSeek生成或有DeepSeek参与编写🥰

## 适用环境
- OpenWrt 25.12+
- 桂电校园网 Dr.COM 认证
- “校园网”（移动/电信/联通可改参数）

## 安装
>自动安装

在SSH中输入
```bash
   wget -O /tmp/install.sh https://raw.githubusercontent.com/ChinaEasternAirlines/GUET--DrCOM--OpenWrt-wget/main/install.sh
```

无外网连接情况下,请手动下载install.sh,并在SSH中运行.

> 手动安装
1. 将 `scripts/wget_auth.sh` 上传到 OpenWrt 的 `/usr/bin/`
2. 赋予执行权限：`chmod +x /usr/bin/wget_auth.sh`
3. 修改脚本中的学号、密码、运营商
4. 添加定时任务：`crontab -e`，加入


***

## 或直接在SSH中操作
### 🚨 第一步：先用 wget 完成认证

注意:
1.密码中如包含 `@`等 符号，在 URL 中必须转义为 `%40`等，否则会打断 URL 结构。
2.此处以联通宽带作实例

```bash
wget -O- "http://10.0.1.5/drcom/login?callback=dr1003&DDDDD=学号%40unicom&upass=密码&0MKKey=123456&R1=0&R3=2&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn"
```

如果执行后返回的内容里包含 `"result":1` 或者 `dr1003(...)` 这样的成功标志，说明认证已经通过。
### 📜 第二步：创建自动认证脚本
1. 在 SSH 里创建一个脚本文件：
```bash
vi /usr/bin/drcom_login.sh
```

2. 输入并保存以下内容：

```bash
#!/bin/sh
if ! ping -c 1 -W 3 223.5.5.5 > /dev/null 2>&1; then
    wget -O- "http://10.0.1.5/drcom/login?callback=dr1003&DDDDD=学号%40unicom&upass=密码&0MKKey=123456&R1=0&R3=2&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn" > /dev/null 2>&1
fi
```

3. 赋予脚本执行权限：
```bash
chmod +x /usr/bin/drcom_login.sh
```

### ⏰ 第三步：设置定时任务，实现断线自动重连

在 SSH 里输入：
```bash
crontab -e
```

添加下面这一行（表示每分钟执行一次脚本，如果断网就自动重连）：

```
* * * * * /usr/bin/drcom_login.sh > /dev/null 2>&1
```

## 致谢

本项目的实现离不开以下开源项目、教程文章和社区资源的帮助，在此向所有作者和贡献者表示诚挚的感谢。

如有侵权或其他处理不当的情况,可通过邮箱```CEAir@outlook.jp```或QQ```2769431445```联系本人QAQ

### 开源项目

- [chainsx/drcom_guet](https://github.com/chainsx/drcom_guet) — 桂电 Dr.COM 认证 Python 实现，提供了认证逻辑与参数格式的核心参考
- [the-eric-kwok/GUET_Dialer_New](https://gitee.com/erickwok404/GUET_Dialer_New) — 桂电宽带无感知认证 Shell 脚本，断线重连机制参考
- [sweetcornna/jlu_drcom](https://github.com/sweetcornna/jlu_drcom) — OpenWrt DrCOM 插件服务教程，提供了 OpenWrt 环境配置指导
- [mchome/dogcom](https://github.com/mchome/dogcom) — DrCOM 认证 C 语言实现，OpenWrt 平台 DrCOM 认证的重要参考

### 教程与文章

- [桂林电子科技大学校园网登录数据包抓取教程](http://blog.wya1.com/article/Internet/details/4321)
- [桂电校园网自动登录：基于 CAS 协议的 HTTP 自动化实践](http://www.0539edu.com/news/4955648/)
- [一键搞定校园网登录：桂林电子科技大学自动化接入指南](https://blog.csdn.net/weixin_29243063/article/details/158937792)
- [关于 OpenWrt 路由器及哆点 Drcom 校园网 WEB 自动登录](https://hez2z.github.io/2024/06/03/)

### 社区与文档

- [恩山无线论坛](https://www.right.com.cn) — 配置与排错经验
- [OpenWrt 官方文档](https://openwrt.org/docs/) — 系统配置参考

感谢所有在开源社区和论坛中无私分享经验的诸位(⁠◍⁠•⁠ᴗ⁠•⁠◍⁠)⁠❤。




