# REST経由で情報を入力する場合の Interoperability（相互運用性機能）のサンプル：InterSystems FAQ

このリポジトリには、REST経由で情報入力がある場合のビジネスサービス作成方法とそのサンプルが含まれています。

- [作成概要](#作成概要)
- [サンプルプロダクションの流れ](#サンプルプロダクションの流れ)
- [作成方法](#作成方法)
- [サンプルのインポート](#サンプルのインポート)

## 作成概要

REST経由で情報を受信できるようにIRISでRESTサーバを作成し、対応するメソッドの中からビジネスサービスを呼び出します。

準備するクラスは以下の通りです。

- RESTディスパッチクラス（%CSP.RESTを継承したクラス）
- アダプタを使用しないビジネスサービスクラス

## サンプルプロダクションの流れ

![](/assets/production.png)

指定URLに対してPOST要求で以下のJSONを送付するとビジネスサービスを呼び出し、後続の処理を呼び出します。

```
{
    "Name":"テスト太郎",
    "Email":"taro@mail.com"
}
```

例では、エンドポイント `/myservice` 以下に `/request` を指定すると[RESTディスパッチクラス：FAQSample.REST.cls](/FAQSample/REST.cls)のメソッド：`PostRequest()` が実行され、渡された情報からプロダクションで使う[メッセージ：FAQSample.Interop.Message](/FAQSample/Interop/Message.cls)を作成し、アダプタ無しの[ビジネスサービス：FAQSample.Interop.NonAdapter](/FAQSample/Interop/NonAdapter.cls)に作成した情報（メッセージ）を渡します。

情報を受け取った[ビジネスサービス：FAQSample.Interop.NonAdapter](/FAQSample/Interop/NonAdapter.cls)は、[ビジネスプロセス：FAQSample.Interop.Process](/FAQSample/Interop/Process.cls)にメッセージを送信します。

メッセージを受信した[ビジネスプロセス：FAQSample.Interop.Process](/FAQSample/Interop/Process.cls)では、メッセージの`Name`プロパティの値の有無によって以下の処理を実行します。

- 値が空の場合：イベントログに「Nameが空です！」と記録します。
- 値が空ではない場合：ファイルアウトバウンドアダプタを使用した[ビジネスオペレーション：FAQSample.Interop.FileOperation](/FAQSample/Interop/FileOperation.cls)にメッセージを渡し、ファイル出力を行います。

![](/assets/process-BPL.png)


> Interoperabilityの仕組みやコンポーネントの役割については、コミュニティの記事：[【はじめてのInterSystems IRIS】Interoperability（相互運用性）を使ってみよう！](https://jp.community.intersystems.com/node/483021)をご参照ください。

## 作成方法

### 1. アダプタのないビジネスサービスを作成する

Ens.BusinessServiceクラスを継承し、アダプタを持たないビジネスサービスクラスを作成します。
（パラメータ：ADAPTERを設定しないビジネスサービスを用意します）

例：[FAQSample.Interop.NonAdapter](/FAQSample/Interop/NonAdapter.cls)
```
Class FAQSample.Interop.NonAdapter Extends Ens.BusinessService
{

/// 第１引数はRESTディスパッチクラスで作成したメッセージが格納されるように変更
Method OnProcessInput(pInput As FAQSample.Interop.Message, Output pOutput As %RegisteredObject, ByRef pHint As %String) As %Status
{
	set status=..SendRequestAsync("FAQSample.Interop.Process",pInput)
    quit status
}

}
```
OnProcessInput()の第1引数のタイプをオリジナルのタイプから入力予定のメッセージクラス名に変更します。（[FAQSample.Interop.Message](/FAQSample/Interop/Message.cls)）

後は、第1引数のメッセージを次にコンポーネントである[ビジネスプロセス：FAQSample.Interop.Process](/FAQSample/Interop/Process.cls)に送信すればいいので、`..SendRequestAsync()`の第2引数にOnProcessInput()の第1引数の情報を渡しています。

コンパイルを行った後、作成したビジネスサービスをプロダクションに追加します。

### 2. ビジネスサービスを呼び出すRESTディスパッチクラスを作成する

%CSP.RESTを継承するRESTディスパッチクラスを作成します。
（例：[FAQSample.REST](/FAQSample/REST.cls)）

`/request`に対してPOST要求で以下JSONを送付したとき、以下のコードが実行されます。

```
{
    "Name":"テスト太郎",
    "Email":"taro@mail.com"
}
```

POST要求のボディに含まれる情報を取得し、サーバ側で処理しやすいようにJSONのダイナミックオブジェクトに変更します。

なおHTTP要求はRESTディスパッチクラスの中では `%request` 変数で操作できます。ボディの情報は`Content`プロパティでアクセスできます。（この変数は[%CSP.Request](https://docs.intersystems.com/irisforhealthlatest/csp/documatic/%25CSP.Documatic.cls?LIBRARY=%25SYS&CLASSNAME=%25CSP.Request)のインスタンスです）
```
set body={}.%FromJSON(%request.Content)
```
ボディのJSONからプロダクションで必要なメッセージを作成します。
```
set request=##class(FAQSample.Interop.Message).%New()
set request.Name=body.Name
set request.Email=body.Email
```
次に、アダプタ無しビジネスサービスのインスタンスを生成します。第1引数はプロダクションに登録したビジネスサービスの名称を指定します。第2引数は生成されたビジネスサービスのインスタンスを格納する変数を参照渡しで指定します。
```
set status=##class(Ens.Director).CreateBusinessService("FAQSample.Interop.NonAdapter",.bs)
```
戻り値を確認し1であればインスタンスの生成に成功しているので、ビジネスサービスのProcessInput()メソッドに作成したメッセージクラスを引数に指定し、実行します。
```
set status=bs.ProcessInput(request)
```
（戻り値を確認し、1が返ってきていれば正常にサービスに情報を送信できています。）

### 3.エンドポイントを作成する

管理ポータルを使用してエンドポイントを作成します。

`管理ポータル > システム管理 > セキュリティ > アプリケーション > ウェブ・アプリケーション > 「新しいウェブ・アプリケーションを作成」ボタンをクリック`

図例では、`/myservice`の名称で`USER`ネームスペースに配置したRESTディスパッチクラスを指定しています。認証方法には「認証なし」と「パスワード」を設定しています。
![](/assets/EndPoint.png)

### 4.テスト

設定が正しく行えているかどうか、RESTクライアントからテストします。
（図例はPostmanを使用しています）

![](/assets/Postman-Auth.png)

次に、ヘッダーを確認します（`Content-Type`に`application/json;charset=utf-8`を指定します）。
![](/assets//Postman-header.png)

ボディを以下のように指定できたら「SEND」ボタンをクリックします。
(`raw`で`JSON`を指定します)
![](/assets/Postman-body.png)

### 5.トレースでメッセージを確認

[ビジネスサービス：FAQSample.Interop.NonAdapter](/FAQSample/Interop/NonAdapter.cls)に入力されたメッセージを確認します。

![](/assets/message-trace1.png)

入力情報のNameの値が空だった場合のメッセージは以下の通りです。（イベントログに「Nameが空です！」と記録されます）
![](/assets/message-trace2.png)


## サンプルのインポート

VSCodeを利用している場合は、IRISに接続後、[FAQSample](/FAQSample)以下のファイルを全て保存します（または[FAQSample](/FAQSample)を右クリックし、「Import and compile」を選択し一括保存＋コンパイルを行います）

この他の方法では、クラス定義の一括エクスポートを行ったファイル：[FAQInteropREST-sample.xml](/FAQInteropREST-sample.xml)をインポートします。

管理ポータルでインポートする場合は、`管理ポータル > システムエクスプローラ > クラス > 対象ネームスペース選択 > インポートボタン`クリック後、[FAQInteropREST-sample.xml](/FAQInteropREST-sample.xml)を選択しインポートします。

インポート後、プロダクション構成画面を開き、**ビジネスオペレーション：FAQSample.Interop.FileOperation** の「ファイル・パス」を適切な場所に変更してください。

**《方法》**

`管理ポータル > Interoperability > 一覧 > プロダクション` に移動したら、**FAQSample.Interop.Production** の行を選択して「開く」ボタンをクリックします。

![](/assets/production-setting.png)

インポート直後はプロダクションが開始していないため、「開始する」ボタンをクリックして開始します。（確認のダイアログが出力されるのですべてOKボタンをクリックします。）

開始後、**オペレーション：FAQSample.Interop.FileOperation** の名称をクリックし、画面右の設定欄にある「ファイル・パス」をファイル出力可能なディレクトリに変更します。

変更後、適用ボタンをクリックします。

この設定により、REST経由で送信した情報が「ファイル・パス」で設定したディレクトリ以下に作成される **test.txt** に出力されます。
