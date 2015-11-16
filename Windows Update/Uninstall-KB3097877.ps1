#Jason - Uninstall KB3097877 specifically. 

#List updates in WMIC
#wmic qfe list

#Uninstall an Update
powershell wusa /uninstall /kb:3097877 /quiet /norestart


wmic qfe list