New-MsolUser -DisplayName "Caleb Sills" -FirstName Caleb `
-LastName Sills -UserPrincipalName calebs@contoso.onmicrosoft.com `
-Department Operations -UsageLocation US -PassWord TempP@@sW0rd `
-LicenseAssignment contoso:ENTERPRISEPACK

Get-MsolAccountSku lists the AccountSkuId, ActiveUnits, WarningUnits, and ConsumedUnits

Set-MsolUserPassword -UserPrincipalName jsmith@western.com -NewPassword welcome@123 -ForceChangePassword $false