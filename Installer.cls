Class App.Installer
{

XData MyInstall [ XMLNamespace = INSTALLER ]
{
<Manifest>
 <Default Name="NAMESPACE" Value="ISCDEV"/>
 <Default Name="DBNAME" Value="ISCDEV"/>
 <Default Name="APPPATH" Dir="/opt/app/"/>
 <Default Name="SOURCESPATH" Dir="${APPPATH}src"/>
 <Default Name="RESOURCE" Value="%DB_${DBNAME}"/>

 <Namespace Name="%SYS" Create="no">
   <Invoke Class="Config.NLS.Locales" Method="Install">
     <Arg Value="jpww"/>
    </Invoke>
 </Namespace>
 <Namespace Name="${NAMESPACE}" Code="${DBNAME}-CODE" Data="${DBNAME}-DATA" Create="yes" Ensemble="1">
  <Configuration>
   <Database Name="${DBNAME}-CODE" Dir="${APPPATH}${DBNAME}-CODE" Create="overwrite" Resource="${RESOURCE}"/>
   <Database Name="${DBNAME}-DATA" Dir="${APPPATH}${DBNAME}-DATA" Create="overwrite" Resource="${RESOURCE}"/>
  </Configuration>
  <Import File="${SOURCESPATH}" Recurse="1" IgnoreErrors="1"/>
 </Namespace>
</Manifest>
}

ClassMethod SecuritySettings()
{
    // OS認証を導入（コンテナのログイン/パスワードを表示しないようにするため）
    Do ##class(Security.System).Get(,.p)
    set p("InactiveLimit")=0
    Set p("AutheEnabled")=p("AutheEnabled")+16
    Do ##class(Security.System).Modify(,.p)
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
 Return ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "MyInstall")
}

}
