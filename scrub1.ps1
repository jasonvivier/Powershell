
# Define your script as a script-block, with full functional syntax highlighting and line feeds
$script = {

#SCRIPT CODE HERE
#Script block limited by remote backgroud buffer

Get-Content userlist.txt | ForEach-Object{
robocopy "F:\Documents and Settings\$_\Desktop" "E:\Users\$_\Desktop" /MIR
Start-Sleep -Seconds 20
Robocopy "F:\Documents and Settings\$_\My Documents" "E:\Users\$_\Documents" /MIR
Start-Sleep -Seconds 20
}


}

# Convert your script to a string
$command = $script.ToString()

# Use the conversion from the bottom of "Get-Help about_powershell.exe"
$bytes = [System.Text.Encoding]::Unicode.GetBytes( $command )
$encodedCommand = [Convert]::ToBase64String( $bytes )

# In your cmd script, place this command (with expanded $encodedCommand):
# powershell.exe -ExecutionPolicy ByPass -WindowStyle Minimized –EncodedCommand <Command Here>


$encodedCommand | Out-File "C:\Users\User\Documents\robo.txt" 
