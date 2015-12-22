Get-WmiObject –query “SELECT * from win32_logicaldisk" | Select-Object DeviceID,Size,FreeSpace 

