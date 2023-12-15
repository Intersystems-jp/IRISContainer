Class FAQSample.REST Extends %CSP.REST
{

Parameter CHARSET = "utf-8";

Parameter CONTENTTYPE = "application/json";

Parameter CONVERTINPUTSTREAM = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/request" Method="POST" Call="PostRequest"/>
    </Routes>
}

/// POST要求で/requestをリクエストされた場合以下メソッドが動きます。
/// Bodyの情報は、%request.Contentで取得できます。
/// 以下形式のJSONデータをBodyに指定すると仮定しています。
/// <pre>
/// {
///     "Name":"テスト太郎",
///     "Email":"taro@mail.com"
/// }
/// </pre>
ClassMethod PostRequest() As %Status
{
    #dim %request As %CSP.Request
    #dim ex As %Exception.AbstractException
    set status=$$$OK
    try {
        //Bodyに含まれているJSON文字を取得しJSONダイナミックオブジェクトに変換する
        set body={}.%FromJSON(%request.Content)
        //Interoperabilityの中で使用するメッセージを作成
        set request=##class(FAQSample.Interop.Message).%New()
        set request.Name=body.Name
        set request.Email=body.Email
        
        //アダプタのないビジネスサービスを実行するため、インスタンスを生成
        set status=##class(Ens.Director).CreateBusinessService("FAQSample.Interop.NonAdapter",.bs)
        $$$ThrowOnError(status)
        set status=bs.ProcessInput(request)
        $$$ThrowOnError(status)
    
        //応答作成
        set res={}
        set res.Status="OK"
        set res.Message="情報送付しました"
        do res.%ToJSON()
    }
    catch ex {
        set status=ex.AsStatus()
    }
    return status
}

}
