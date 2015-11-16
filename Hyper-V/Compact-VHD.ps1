# Prompt for the Hyper-V Server to use
$HyperVServer = Read-Host "Specify the Hyper-V Server to use (enter '.' for the local computer)"
 
# Get name for VHD
$VHDName = Read-Host "Specify the name of the virtual had disk to compact"
 
# Get the Msvm_ImageManagementService object
$ImageManagementService = gwmi Msvm_ImageManagementService -namespace "root\virtualization" -computername $HyperVServer
 
# Compact the VHD
$result = $ImageManagementService.CompactVirtualHardDisk($VHDName)
 
#Return success if the return value is "0"
if ($Result.ReturnValue -eq 0)
   {write-host "The virtual hard disk has been compacted."} 
 
#If the return value is not "0" or "4096" then the operation failed
ElseIf ($Result.ReturnValue -ne 4096)
   {write-host "The virtual hard disk has not been compacted.  Error value:" $Result.ReturnValue}
 
  Else
   {#Get the job object
    $job=[WMI]$Result.job
 
    #Provide updates if the jobstate is "3" (starting) or "4" (running)
    while ($job.JobState -eq 3 -or $job.JobState -eq 4)
      {write-host "Compacting. "$job.PercentComplete "% complete"
       start-sleep 1
 
       #Refresh the job object
       $job=[WMI]$Result.job}
 
     #A jobstate of "7" means success
    if ($job.JobState -eq 7)
       {write-host "The virtual hard disk has been compacted."}
      Else
       {write-host "The virtual hard disk has not been compacted."
        write-host "ErrorCode:" $job.ErrorCode
        write-host "ErrorDescription" $job.ErrorDescription}
   }