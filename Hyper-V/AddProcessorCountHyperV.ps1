#Shutdow VM

Stop-VM -Name SLC-DC

#Set Processor count 

Set-VMProcessor -VMName "SLC-DC" -count 2 

#Start VM

Start-VM -Name SLC-DC
