Try {
 $objAutoUpdate =New-Object -ComObject "Microsoft.Update.AutoUpdate"
 $objSett = $objAutoUpdate.Settings

 # Notification Level 1 is ~Never check for updates~
 # Notification Level 2 is ~Check for updates but let me choose whether to download and install them~ 
 # Notification Level 3 is ~Download updates but let me choose whether to install them~
 # Notification Level 4 is ~Install updates automatically~

 # Change the value of SCHEDULED_INSTALLATIOM to one of the above values 
 $SCHEDULED_INSTALLATION = 2 
 $objSett.NotificationLevel = $SCHEDULED_INSTALLATION
 #Save any changes to automatic updates 
 $objSett.Save() 
 switch ($objSett.NotificationLevel) 
 {
   1 {"Never check for updates"}
   2 {"Check for updates but let me choose whether to download and install them"}
   3 {"Download updates but let me choose whether to install them"}
   4 {"Install updates automatically" 
     # If you want to chage the day that updates are automatically installed
     #Note  ~~~ 1=Sunday, 7=Saturdat etc. ~~~ 
     $objSett.ScheduledInstallationDay = 2 
     # If you want to chage the time that updates are automatically installed, change the value below, 1=1:00 a.m., 16=4:00 p.m. etc 
     $objSett.ScheduledInstallationTime = 12
     $objSett.Save() }
}
Write-Host "Script Check passed"
Exit 0
}
Catch
{
Write-Host("Script Check Failed")
Exit 1001 
}