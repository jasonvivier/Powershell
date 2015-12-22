Write-host "Please enter user alias:"
$UserName = read-host
$EmailAddress = "$username"

Write-host "Please enter new password:"
$Password = read-host

Set-MsolUser  -UserPrincipalName $EmailAddress -StrongPasswordRequired $False
Set-MsolUserPassword -UserPrincipalName $EmailAddress -NewPassword $Password -ForceChangePassword $false

Write-host "Completed.  Password changed to $Password for account $EmailAddress"