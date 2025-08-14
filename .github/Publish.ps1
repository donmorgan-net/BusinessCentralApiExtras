#Workaround for known issue: https://github.com/PowerShell/PSResourceGet/issues/1806
Get-PSResourceRepository | out-null


$ModulePath = ".\Module\"
Publish-PSResource -Path $ModulePath -ApiKey $Env:APIKEY
