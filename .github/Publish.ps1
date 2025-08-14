#Workaround for known issue: https://github.com/PowerShell/PSResourceGet/issues/1806
Get-PSResourceRepository | out-null

#Install required module or Publish-PsResource will fail
Install-Module BusinessCentralApi -Scope CurrentUser -Force

$ModulePath = ".\Module\"
Publish-PSResource -Path $ModulePath -ApiKey $Env:APIKEY
