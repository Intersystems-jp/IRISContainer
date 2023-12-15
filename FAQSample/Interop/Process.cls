/// 
Class FAQSample.Interop.Process Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='FAQSample.Interop.Message' response='Ens.Response' height='2000' width='2000' >
<sequence xend='553' yend='375' >
<if name='Nameが空' condition='request.Name=""' xpos='599' ypos='239' xend='308' yend='335' >
<true>
<code name='Log出力' xpos='965' ypos='324' >
<![CDATA[ $$$LOGINFO("Nameが空です！")]]>
</code>
</true>
<false>
<call name='ファイル出力' target='FAQSample.Interop.FileOperation' async='1' xpos='369' ypos='269' >
<request type='FAQSample.Interop.Message' >
<assign property="callrequest" value="request" action="set" />
</request>
</call>
</false>
</if>
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
