[简体中文](./README.md) | [繁體中文](./README.zh-TW.md) | [English](./README.en.md) | **日本語**
# 桂林電子科技大学 DrCOM OpenWrt wget 自動認証

桂林電子科技大学（GUET）キャンパスネットワークの DrCOM 認証用 OpenWrt 自動ログインスクリプトです。`wget` を使用して実装され、切断時の自動再接続をサポートします。
> 以下の内容は DeepSeek によって生成されたか、DeepSeek が作成に関与しています🥰

## 適用環境
- OpenWrt 25.12+
- GUET キャンパスネットワーク DrCOM 認証
- 「キャンパスネットワーク」（モバイル/テレコム/ユニコムのパラメータは変更可能）

## インストール
> 自動インストール

SSH で以下を入力してください：
```bash
wget -O /tmp/install.sh https://raw.githubusercontent.com/ChinaEasternAirlines/GUET--DrCOM--OpenWrt-wget/main/install.sh
```

外部ネットワークに接続できない場合は、手動で `install.sh` をダウンロードし、SSH で実行してください。

> 手動インストール
1. `scripts/wget_auth.sh` を OpenWrt の `/usr/bin/` にアップロードします
2. 実行権限を付与します：`chmod +x /usr/bin/wget_auth.sh`
3. スクリプト内の学籍番号、パスワード、通信キャリアを変更します
4. 定期タスクを追加します：`crontab -e` を実行し、以下を追加します：
   `* * * * * /usr/bin/wget_auth.sh > /dev/null 2>&1`

***

## または SSH で直接操作する
### 🚨 ステップ 1：まず wget を使用して認証を完了する

注意：
1. パスワードに `@` などの記号が含まれている場合、URL 内では `%40` などにエスケープする必要があります。そうしないと URL 構造が壊れます。
2. ここではユニコム（中国聯通）ブロードバンドを例にしています。

```bash
wget -O- "http://10.0.1.5/drcom/login?callback=dr1003&DDDDD=[学籍番号]%40unicom&upass=[パスワード]&0MKKey=123456&R1=0&R3=2&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn"
```

実行後の戻り値に `"result":1` や `dr1003(...)` などの成功フラグが含まれていれば、認証は成功しています。

### 📜 ステップ 2：自動認証スクリプトの作成
1. SSH でスクリプトファイルを作成します：
```bash
vi /usr/bin/drcom_login.sh
```

2. 以下の内容を入力して保存します：

```bash
#!/bin/sh
if ! ping -c 1 -W 3 223.5.5.5 > /dev/null 2>&1; then
    wget -O- "http://10.0.1.5/drcom/login?callback=dr1003&DDDDD=[学籍番号]%40unicom&upass=[パスワード]&0MKKey=123456&R1=0&R3=2&R6=0&para=00&v6ip=&terminal_type=1&lang=zh-cn" > /dev/null 2>&1
fi
```

3. スクリプトに実行権限を付与します：
```bash
chmod +x /usr/bin/drcom_login.sh
```

### ⏰ ステップ 3：定期タスクを設定し、自動再接続を実現する

SSH で以下を入力します：
```bash
crontab -e
```

以下の行を追加します（1分ごとにスクリプトを実行し、切断されていれば自動的に再接続します）：

```
* * * * * /usr/bin/drcom_login.sh > /dev/null 2>&1
```

## 謝辞

本プロジェクトの実現にあたり、以下のオープンソースプロジェクト、チュートリアル記事、およびコミュニティリソースの助けを借りました。すべての作者と貢献者に心より感謝申し上げます。

権利侵害や不適切な処理がある場合は、メール CEAir@outlook.jp または QQ 2769431445 までご連絡ください QAQ

### AI
- DeepSeek～

### オープンソースプロジェクト

- [chainsx/drcom_guet](https://github.com/chainsx/drcom_guet) — GUET Dr.COM 認証の Python 実装。認証ロジックとパラメータ形式の核心的な参考になりました。
- [the-eric-kwok/GUET_Dialer_New](https://gitee.com/erickwok404/GUET_Dialer_New) — GUET ブロードバンドのシームレス認証 Shell スクリプト。自動再接続メカニズムの参考になりました。
- [sweetcornna/jlu_drcom](https://github.com/sweetcornna/jlu_drcom) — OpenWrt DrCOM プラグインサービスのチュートリアル。OpenWrt 環境設定のガイドになりました。
- [mchome/dogcom](https://github.com/mchome/dogcom) — DrCOM 認証の C 言語実装。OpenWrt プラットフォームでの DrCOM 認証の重要な参考資料です。

### チュートリアルと記事

- [桂林電子科技大学キャンパスネットワークログインデータパケット取得チュートリアル](http://blog.wya1.com/article/Internet/details/4321)
- [GUET キャンパスネットワーク自動ログイン：CAS プロトコルに基づく HTTP 自動化の実践](http://www.0539edu.com/news/4955648/)
- [ワンクリックでキャンパスネットワークログイン：桂林電子科技大学自動アクセスガイド](https://blog.csdn.net/weixin_29243063/article/details/158937792)
- [OpenWrt ルーターと哆点 Drcom キャンパスネットワーク WEB 自動ログインについて](https://hez2z.github.io/2024/06/03/)

### コミュニティとドキュメント

- [恩山無線フォーラム (Enshan Wireless Forum)](https://www.right.com.cn) — 設定とトラブルシューティングの経験
- [OpenWrt 公式ドキュメント](https://openwrt.org/docs/) — システム設定の参考資料

オープンソースコミュニティとフォーラムで惜しみなく経験を共有してくださった皆様に感謝します (⁠◍⁠•⁠ᴗ⁠•⁠◍⁠)⁠❤
