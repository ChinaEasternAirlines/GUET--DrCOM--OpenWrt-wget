[简体中文](./README.md) | **繁體中文** | [English](./README.en.md) | [日本語](./README.ja.md)
# 桂電 DrCOM OpenWrt wget 自動認證

桂林電子科技大學校園網路 DrCOM 認證的 OpenWrt 自動登入腳本，使用 `wget` 實現，支援斷線重連。
> 以下內容由 DeepSeek 產生或有 DeepSeek 參與編寫🥰

## 適用環境
- OpenWrt 25.12+
- 桂電校園網路 DrCOM 認證
- 「校園網路」（移動/電信/聯通可改參數）

## 安裝
> 自動安裝

在 SSH 中輸入：
```bash
wget -O /tmp/install.sh https://raw.githubusercontent.com/ChinaEasternAirlines/GUET--DrCOM--OpenWrt-wget/main/install.sh
```

無外網連線情況下，請手動下載 `install.sh`，並在 SSH 中執行。

> 手動安裝
1. 將 `scripts/wget_auth.sh` 上傳到 OpenWrt 的 `/usr/bin/`
2. 賦予執行權限：`chmod +x /usr/bin/wget_auth.sh`
3. 修改腳本中的學號、密碼、電信商
4. 新增排程任務：`crontab -e`，加入
   `* * * * * /usr/bin/wget_auth.sh > /dev/null 2>&1`

***

## 或直接在 SSH 中操作
### 🚨 第一步：先用 wget 完成認證

注意：
1. 密碼中如包含 `@` 等符號，在 URL 中必須轉義為 `%40` 等，否則會打斷 URL 結構。
2. 此處以聯通寬頻作實例

```bash
wget -O- "http://10.0.1.5/drcom/login?callback=dr1003&DDDDD=學號%40unicom&upass=密碼&0MKKey=123456&R1=0&R3=2&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn"
```

如果執行後回傳的內容裡包含 `"result":1` 或者 `dr1003(...)` 這樣的成功標誌，說明認證已經通過。

### 📜 第二步：建立自動認證腳本
1. 在 SSH 裡建立一個腳本檔案：
```bash
vi /usr/bin/drcom_login.sh
```

2. 輸入並儲存以下內容：

```bash
#!/bin/sh
if ! ping -c 1 -W 3 223.5.5.5 > /dev/null 2>&1; then
    wget -O- "http://10.0.1.5/drcom/login?callback=dr1003&DDDDD=學號%40unicom&upass=密碼&0MKKey=123456&R1=0&R3=2&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn" > /dev/null 2>&1
fi
```

3. 賦予腳本執行權限：
```bash
chmod +x /usr/bin/drcom_login.sh
```

### ⏰ 第三步：設定排程任務，實現斷線自動重連

在 SSH 裡輸入：
```bash
crontab -e
```

加入下面這一行（表示每分鐘執行一次腳本，如果斷網就自動重連）：

```
* * * * * /usr/bin/drcom_login.sh > /dev/null 2>&1
```

## 致謝

本專案的實現離不開以下開源專案、教學文章和社群資源的幫助，在此向所有作者和貢獻者表示誠摯的感謝。

如有侵權或其他處理不當的情況，可透過信箱 ```CEAir@outlook.jp``` 或 QQ ```2769431445``` 聯絡本人QAQ

### 開源專案

- [chainsx/drcom_guet](https://github.com/chainsx/drcom_guet) — 桂電 Dr.COM 認證 Python 實現，提供了認證邏輯與參數格式的核心參考
- [the-eric-kwok/GUET_Dialer_New](https://gitee.com/erickwok404/GUET_Dialer_New) — 桂電寬頻無感知認證 Shell 腳本，斷線重連機制參考
- [sweetcornna/jlu_drcom](https://github.com/sweetcornna/jlu_drcom) — OpenWrt DrCOM 外掛服務教學，提供了 OpenWrt 環境設定指導
- [mchome/dogcom](https://github.com/mchome/dogcom) — DrCOM 認證 C 語言實現，OpenWrt 平台 DrCOM 認證的重要參考

### 教學與文章

- [桂林電子科技大學校園網路登入資料包擷取教學](http://blog.wya1.com/article/Internet/details/4321)
- [桂電校園網自動登入：基於 CAS 協定的 HTTP 自動化實踐](http://www.0539edu.com/news/4955648/)
- [一鍵搞定校園網登入：桂林電子科技大學自動化接入指南](https://blog.csdn.net/weixin_29243063/article/details/158937792)
- [關於 OpenWrt 路由器及哆點 Drcom 校園網 WEB 自動登入](https://hez2z.github.io/2024/06/03/)

### 社群與文件

- [恩山無線論壇](https://www.right.com.cn) — 設定與排錯經驗
- [OpenWrt 官方文件](https://openwrt.org/docs/) — 系統設定參考

感謝所有在開源社群和論壇中無私分享經驗的諸位(⁠◍⁠•⁠ᴗ⁠•⁠◍⁠)⁠❤。
