w32tm /config /manualpeerlist:pool.ntp.org /syncfromflags:MANUAL
Stop-Service w32time
Start-Service w32time