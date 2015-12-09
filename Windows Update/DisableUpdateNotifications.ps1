Try {﻿Clear-Host
$TPathbase = "hkcu:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$RegEnt = (Get-ItemProperty -Path $TPathbase -Name EnableBalloonTips).EnableBalloonTips
If ($RegEnt -eq 0) {
Clear-Host
Write-Output "BalloonTips are already Disabled"
Exit 0
}
Else {
$Value =(Get-Itemproperty $TPathbase -Name "EnableBalloonTips"-ErrorAction SilentlyContinue) 
 if($Value -ne 0){Set-ItemProperty -Path $TPathBase -Name EnableBalloonTips -Value 0 -Type DWord}
Clear-Host
 Write-Output "BalloonTips Have Been Disabled"
 Exit 0
 }