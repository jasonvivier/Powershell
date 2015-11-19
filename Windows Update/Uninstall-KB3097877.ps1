wusa /uninstall /kb:3097877 /quiet /norestart

wmic qfe list  | Where-Object {$_.HotFixID -eq "KB3106932"} | Select-Object -Property InstallDate, HotFixID, InstalledOn | Format-List


