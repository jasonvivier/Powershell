# Variables and Conversions

$var=Get-WmiObject –query “SELECT * from win32_logicaldisk" | Where-Object {$_.DeviceID -notlike "*$env:SystemDrive*"} | Measure-Object -Property FreeSpace -Maximum
$MaxValue = $var.Maximum

$var2=Get-WmiObject –query “SELECT * from win32_logicaldisk" | Where-Object {$_.FreeSpace -eq $MaxValue}
$SelectedDrive = $var2.DeviceID

$RandomName = "SoftDist" + (get-date -uformat %s)

$SizeOfSoftDist = Get-ChildItem C:\Windows\SoftwareDistribution -Recurse | Measure-Object -property length -sum

$SizeOfSoftDistDoubled = $SizeOfSoftDist.Sum * 2

$Failure = "We are sorry to inform you that the size of the " + $SelectedDrive + " Drive does not meet the minimum requirement of " + $SizeOfSoftDistDoubled + " bytes to complete this request."

# Processing

if ($MaxValue -gt $SizeOfSoftDistDoubled) {

net stop WuAuServ

Rename-Item $env:SystemDrive:\Windows\SoftwareDistribution SoftwareDistribution.old

Rename-Item $SelectedDrive\SoftwareDistribution.old $RandomName

Move-Item $env:SystemDrive:\Windows\SoftwareDistribution.old -Destination $SelectedDrive

net start WuAuServ

}
Else {
Write-Host $Failure
} 
