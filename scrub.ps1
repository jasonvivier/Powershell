﻿$prompt = 'Choose the process you want to terminate:'  Get-Process |    Where-Object { $_.MainWindowTitle } |   ForEach-Object {     New-Object PSObject -Property @{$prompt = $_ | Add-Member -MemberType ScriptMethod -Name ToString -Force -Value  { '{0} [{1}]' -f $this.Description, $this.Id } -PassThru }   } |   Out-GridView -OutputMode Single -Title $prompt |   Select-Object -ExpandProperty $prompt |   Stop-Process -WhatIf  