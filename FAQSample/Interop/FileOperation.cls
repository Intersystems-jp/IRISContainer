Class FAQSample.Interop.FileOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.File.OutboundAdapter";

Property Adapter As EnsLib.File.OutboundAdapter;

/// 出力ファイル名を指定してください
Property OutputFileName As %String [ InitialExpression = "test.txt" ];

Parameter SETTINGS = "OutputFileName:サンプル用設定,ReplyCodeActions,RetryInterval,AlertRetryGracePeriod:Alerting,FailureTimeout,QueueCountAlert:Alerting,QueueWaitAlert:Alerting,SendSuperSession";

Method OutputFile(pInput As FAQSample.Interop.Message, ByRef pOutput As %RegisteredObject) As %Status
{
    set text=$ZDATETIME($H,16)_$$$NL
    set text=text_"名前:"_pInput.Name_"||Email:"_pInput.Email_$$$NL
    set status=..Adapter.PutString(..OutputFileName,text)
    return $$$OK
}

/// Description
XData MessageMap
{
<MapItems>
<MapItem MessageType="FAQSample.Interop.Message">
    <Method>OutputFile</Method>
</MapItem>
</MapItems>
}

}
