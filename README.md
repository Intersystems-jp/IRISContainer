# IRIS開発環境用コンテナサンプル
ウェビナーに合わせてvscodeの拡張機能dockerからコンテナを作成、起動できるサンプルを作成しました。

コミュニティ版IRISは、ファイルdocker-compose-community.yml上にて右クリックし「compose up」を選択するとコンテナを作成し、起動します。

本番用IRISはlicenseフォルダにライセンスキー(iris.key)を配置した上で docker-compose-iris.yml 上にて右クリック、「Compose up」を選択します。

## ファイルの説明

各ファイルの詳細については、[こちら](https://jp.community.intersystems.com/node/545786)をご参照ください。

| ファイル名| 説明 |
|----------|------|
|iris/Dockerfile| IRISコンテナbuildファイル|
|src/Sample/Person.cls| ロードクラスのサンプル|
|web/CSP.conf|Web server 設定|
|web/CSP.ini|Web Gateway 設定|
|docker-compose-community.yml| iris community editionコンテナ用 |
|docker-compose-iris.yml|irisコンテナ+Web serverコンテナ用|
|Installer.cls|IRISインストールクラスファイル|
|README.md| Readmeファイル|

## IRISのバージョンを指定する場合

特定のIRISバージョンを使用する場合、docker-compose-*.ymlのbuildセクションにあるargsセクションのVERパラメータを修正ください。

```  
    args:
       PRODNAME: "iris"
       COMEDITION: "-community"
       VER: 2022.1.4.812.0
```
## ライブラリ等のクラスをロードする場合

ライブラリなど開発環境にクラスをロードする必要がある場合、
srcフォルダの下に配置するとコンテナ作成時にロードします。

```
    src/Sample/Person.cls
```

