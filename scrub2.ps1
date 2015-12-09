
Get-Content list.txt | ForEach-Object {

Connect-Mstsc -ComputerName 10.0.0.3 -User $_ -Password 1234

Start-Sleep -Seconds 60

Stop-Process -Name mstsc

}


Get-Content userlist.txt | ForEach-Object{

robocopy "\\192.168.220.21\d$\Documents and settings\$_\Desktop" "\\192.168.220.28\e$\Users\$_\Desktop" /MIR 
}


Get-Content userlist.txt | ForEach-Object{
robocopy "F:\Documents and Settings\$_\Desktop" "E:\Users\$_\Desktop" /MIR
Start-Sleep -Seconds 20
Robocopy "F:\Documents and Settings\$_\My Documents" "E:\Users\$_\Documents" /MIR
Start-Sleep -Seconds 20
}


$listPath = "d:\temp\csvs\test.csv"
 $oldhome = "D:\DFSRoots\Public\User Shared Folders\"
 $newhome = "D:\DFSRoots\Public\Users\Senior School\Pupils\test1\"
 $list = import-csv $listPath
 foreach($user in $list)
 {
     $path = Join-Path $oldhome -childpath $user.username
     move-item $path $newhome
 }