Class FAQSample.Interop.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="FAQSample.Interop.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="FAQSample.Interop.NonAdapter" Category="" ClassName="FAQSample.Interop.NonAdapter" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="FAQSample.Interop.FileOperation" Category="" ClassName="FAQSample.Interop.FileOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="FilePath">/usr/irissys/mgr/user/</Setting>
  </Item>
  <Item Name="FAQSample.Interop.Process" Category="" ClassName="FAQSample.Interop.Process" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
