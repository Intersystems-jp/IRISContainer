Class FAQSample.Interop.NonAdapter Extends Ens.BusinessService
{

/// 第１引数はRESTディスパッチクラスで作成したメッセージが格納されるように変更
Method OnProcessInput(pInput As FAQSample.Interop.Message, Output pOutput As %RegisteredObject, ByRef pHint As %String) As %Status
{
	set status=..SendRequestAsync("FAQSample.Interop.Process",pInput)
    quit status
}

}
