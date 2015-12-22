<#

    .PURPOSE
        Script will output a full list of mobile devices that have not
        synced in 14 days

    . EXAMPLES
        PS> InactiveMobiles.ps1

    .OUTPUT
        UserPrincipalname
        DeviceModel
        LastSuccessSync

    .NOTES
        For Wave 14 Customers change the Get-MobileDeviceStatistics to Get-ActiveSyncDeviceStatistics

    .AUTHOR
        Dan Rose

#>

# Gather Mailboxes
$users = Get-Mailbox -ResultSize Unlimited 

foreach ($user in $users) {

    # Get mobiles that have not synced for the last x days
    $mobiles = Get-MobileDeviceStatistics -Mailbox $user.identity |
        where {$_.LastSuccessSync -lt (Get-Date).AddDays(-14)} |
        select DeviceModel,LastSuccessSync

   
    foreach ($mobile in $mobiles) {
    
        $ObjProperties = New-Object PSObject

        Add-Member -InputObject $ObjProperties -MemberType NoteProperty -Name "UserPrincipalName" -Value $user.userprincipalname
        Add-Member -InputObject $ObjProperties -MemberType NoteProperty -Name "DeviceModel" -Value $mobile.DeviceModel
        Add-Member -InputObject $ObjProperties -MemberType NoteProperty -Name "LastSuccessSync" -Value $mobile.LastSuccessSync

        $objProperties
    
        # Output to file
        $MobileString = "$($user.userprincipalname),$($mobile.DeviceModel),$($mobile.LastSuccessSync)"
        Out-File -FilePath "c:\FTP\inactivemobiles.csv" -InputObject $MobileString  -Encoding UTF8 -append

    }
}

Remove-PSSession $Script:Session