################################################################################################
##Script:           Clean-WinSXS.ps1
##
##Description:      Cleans disk space by deleting temp files and obsolete windows updates and
#+                  service pack files. Uses disk cleanup utility and DISM (DISM only on 2008 R2
#+                  and on). Doesn't require any reboots!
##Created by:       Noam Wajnman
##Creation Date:    August 26, 2014
##Updated:          September 22, 2014
##Modified:         11.17.2015 By Jason V. 
##Added:            Windows 7, 8, 10 procedures and Set-ExecutionPolicy
################################################################################################
#FUNCTIONS
function Get-WindowsVersion {
    #############################################################################################
    ##Function:         Get-WindowsVersion
    ##
    ##Description:      Gets the windows version of the computer.
    ##
    ##Created by:       Noam Wajnman
    ##Creation Date:    August 26, 2014 
    ##############################################################################################
    $version = (gwmi win32_Operatingsystem).Caption
    return $version.trim()  
}
function Get-OSArchitecture {
    #Function taken from https://www.zabbix.com/forum/showthread.php?t=37441
    #Written by Pierre-Emmanuel Turcotte
    ### Get architecture x86 or x64...  
    $os = Get-WMIObject -Class win32_operatingsystem        
    if($os.OSArchitecture -ne $null) {
        # Architecture can be determined by $os.OSArchitecture...
        if ($os.OSArchitecture -eq "64-bit") {
            write-host "64bit system detected!"
            $osArch = "win64"
        }
        elseif($os.OSArchitecture -eq "32-bit") {
            write-host "32bit system detected!"
            $osArch = "win32"
        }       
    }
    else {
        write-host "`t Windows Pre-2008"
        # Here have to analyze $os.Caption to determine architecture...
        if($os.Caption  -match "x64") {
            write-host "64bit system detected!"
            $osArch = "win64"
        }
        else {          
            write-host "32bit system detected!"
            $osArch = "win32"
        }
    }   
    return $osArch
}
function Copy-CleanmgrFiles {
    #############################################################################################
    ##Function:         Copy-CleanmgrFiles
    ##
    ##Description:      Copies files necessary to run the disk cleanup utility to the system
    ##
    ##Created by:       Noam Wajnman
    ##Creation Date:    August 26, 2014 
    ##############################################################################################
    Write-Host "Getting OS architecture..."
    $OSArch = Get-OSArchitecture
    switch ($OSArch) {      
        "win32" { $OSArchStr = "c:\windows\winsxs\x86_microsoft-windows-cleanmgr*" }
        "win64" { $OSArchStr = "c:\windows\winsxs\amd64_microsoft-windows-cleanmgr*" }
    }   
    if (!(Test-Path "c:\windows\system32\cleanmgr.exe")) {
        $cleanmgr = (Get-ChildItem -Recurse $OSArchStr | ? {$_.Name -eq "cleanmgr.exe"}).FullName        
        Write-Host "Copying $cleanmgr to c:\windows\System32\..."
        copy-item -Path $cleanmgr -Destination "c:\windows\System32\"
    }   
    if (!(Test-Path "c:\windows\system32\En-Us\cleanmgr.exe.mui")) {    
        $cleanmgr_mui = (Get-ChildItem -Recurse $OSArchStr | ? {$_.Name -eq "cleanmgr.exe.mui"}).FullName
        Write-Host "Copying $cleanmgr_mui to c:\windows\System32\En-Us\..."
        copy-item -Path $cleanmgr_mui -Destination "c:\windows\System32\En-Us\"
    }
}
function Install-MSU {
    #############################################################################################
    ##Function:         Install-MSU
    ##
    ##Description:      Installs the hotfix KB2852386 on the computer. THis is necessary to include
    #+                  the windows updates and service pack files when running the disk cleanup
    #+                  utility (only on win 2008 R2)
    ##
    ##Created by:       Noam Wajnman
    ##Creation Date:    August 26, 2014 
    ##Modified Data 11.17.2015 - Jason - Added procedure
    ##http://www.microsoft.com/downloads/details.aspx?FamilyId=3c2805f2-0867-4c5e-addf-9379efa99829
    ##############################################################################################
    #VARIABLES
    $file_KB2852386 = "$dir\Files\Windows6.1-KB2852386-v2-x64.msu"
    #FUNCTION MAIN
    #If WIN_VER 7 OS_ARCH x86 
   
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"  
    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"  
    if (!(Get-HotFix -Id "KB2852386")) {
        Write-Host "Installing update KB2852386...."
        start -wait $file_KB2852386 -argumentlist "/quiet /norestart"
        sleep 3
        if (!(Get-HotFix -Id "KB2852386")) {
            Write-Host "Error - install of update KB2852386 failed.Please fix the problem and restart the script."
            exit
        }
        else {
            Write-Host "Install of update KB2852386 succeeded!"
        }
    }
    else {
        Write-Host "Update is already installed. Proceeding..."
    }
}
function Set-CleanMgrRegKeys { 
    #############################################################################################
    ##Function:         Set-CleanMgrRegKeys
    ##
    ##Description:      Sets the stateflags reg keys to the correct values so the disk cleanup is
    #+                  ready to run.
    ##
    ##Created by:       Noam Wajnman
    ##Creation Date:    August 26, 2014 
    ##############################################################################################  
    $VolumeCachesPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
    #use static SageSet Value.
    $SageSet = "0010"
    #StateFlag values
    $StateFlagClean = 2 
    $StateFlags = "StateFlags$SageSet" 
    #Set all VolumeCache keys to StateFlags = 0 to prevent cleanup. After, set the proper keys to 2 to allow cleanup.
    $SubKeys = Get-Childitem $VolumeCachesPath
    Foreach ($Key in $SubKeys)
    {
        Set-ItemProperty -Path $Key.PSPath -Name $StateFlags -Value $StateFlagClean
    }    
    #print relevant reg keys
    $SubKeys = Get-Childitem $VolumeCachesPath
    $VolumeCaches = @()
    Foreach ($Key in $SubKeys)
    {   
        $VolumeCache = '' | select "Name","StateFlags"
        $VolumeCache.Name = (Get-ItemProperty -Path $Key.PSPath).PSChildName
        $VolumeCache.StateFlags = (Get-ItemProperty -Path $Key.PSPath).$StateFlags
        $VolumeCaches += $VolumeCache
    }   
    Write-host ($VolumeCaches | Out-String)
}
function Run-CleanMgr {
    #############################################################################################
    ##Function:         Run-CleanMgr
    ##
    ##Description:      Runs the disk cleanup utility with the configured sageset.
    ##
    ##Created by:       Noam Wajnman
    ##Creation Date:    August 26, 2014 
    ##############################################################################################
    $SageSet = "0010"
    try {
        Write-Host "Starting CleanMgr.exe... "           
        
        &"C:\Windows\System32\Cleanmgr.exe" + " /sagerun:$SageSet"           
        Wait-Process cleanmgr        
        Write-Host "CleanMgr.exe has completed the disk cleanup..."       
    }
    catch
    {
        Write-Host -ForegroundColor Red "ERROR!"           
        Write-Host $Error[0].Exception
        exit
    }
}
function DISM-Clean_SuperSeded {
    #############################################################################################
    ##Function:         DISM-Clean-SuperSeded
    ##
    ##Description:      Runs the DISM cleanup with the /spsuperseded switch.
    ##
    ##Created by:       Noam Wajnman
    ##Creation Date:    September 21, 2014  
    ##############################################################################################
    $exe = "dism.exe"
    $arg1 = "/online"
    $arg2 = "/cleanup-image"
    $arg3 = "/spsuperseded"
    $command = "$exe $arg1 $arg2 $arg3"
    Invoke-Expression $command
}
function DISM-Clean_StartComponentCleanup {
    #############################################################################################
    ##Function:         DISM-Clean-StartComponentCleanup
    ##
    ##Description:      Runs the DISM cleanup with the /StartComponentCleanup switch.
    ##
    ##Created by:       Noam Wajnman
    ##Creation Date:    September 21, 2014  
    ##############################################################################################
    $exe = "dism.exe"
    $arg1 = "/online"
    $arg2 = "/cleanup-image"   
    $arg3 = "/StartComponentCleanup"
    $command = "$exe $arg1 $arg2 $arg3"
    Invoke-Expression $command
}
function Cleanup-Tempfolders {
    #############################################################################################
    ##Function:         Cleanup-Tempfolders
    ##
    ##Description:      Deletes the contents of the given temp folders.
    ##
    ##Created by:       Noam Wajnman
    ##Creation Date:    August 26, 2014     
    ##############################################################################################
    #VARIABLES
    $tempfolders = @("c:\temp\*","c:\tmp\*","c:\Windows\temp\*")
    #FUNCTION MAIN
    $tempfolders | % {
        if (Test-Path $_) {
            remove-item $_ -Recurse -Force -ErrorAction "SilentlyContinue"
        }
    }   
}
function Get-FreeDiskSpace {
    #############################################################################################
    ##Function:         Cleanup-Tempfolders
    ##
    ##Description:      Gets the free disk space and returns it in number of GBs rounded to 2 
    #+                  decimals
    ##
    ##Created by:       Noam Wajnman
    ##Creation Date:    August 26, 2014     
    ##############################################################################################
    $FreeSpace = (gwmi win32_logicaldisk | ? { $_.DeviceID -eq "C:"}).FreeSpace
    $FreeGBs = "{0:N2}" -f ($FreeSpace / 1GB)
    return $FreeGBs
}
#VARIABLES
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
#SCRIPT MAIN
Set-ExecutionPolicy Bypass -Force
clear
$StartTime = Get-Date
#Get Free disk space on C: before script run.
$BeforeScriptFreeDiskSpace = Get-FreeDiskSpace
#Based on the OS of the server run a set of different clean tasks.
switch -regex (Get-WindowsVersion) {
       ".+Server.+2008 [^R2]{2}.+" {
        Write-Host "Found Windows Server 2008"
        Copy-CleanmgrFiles
        Set-CleanMgrRegKeys
        Run-CleanMgr
        Cleanup-tempfolders
    }
    ".+Windows.+10" {
    Write-Host "Found Windows 10"
        Copy-CleanmgrFiles
        Set-CleanMgrRegKeys
        Run-CleanMgr
        Cleanup-tempfolders
    }
    ".+Windows.+8" {
    Write-Host "Found Windows 8"
        Copy-CleanmgrFiles
        Set-CleanMgrRegKeys
        Run-CleanMgr
        Cleanup-tempfolders
    }
    ".+Windows.+7" {
    Write-Host "Found Windows 7"
        Copy-CleanmgrFiles
        Set-CleanMgrRegKeys
        Run-CleanMgr
        Cleanup-tempfolders
    }
    ".+Server.+2008 [R2]{2}.+" {
        Write-Host "Found Windows Server 2008 R2"      
        Copy-CleanmgrFiles
        Install-MSU
        Set-CleanMgrRegKeys
        Run-CleanMgr
        DISM-Clean_SuperSeded
        Cleanup-tempfolders
    }
    ".+Server.+2012 [^R2]{2}.+" {
        Write-Host "Found Windows Server 2012" 
        Copy-CleanmgrFiles
        Set-CleanMgrRegKeys
        Run-CleanMgr
        DISM-Clean_SuperSeded
        DISM-Clean_StartComponentCleanup
        Cleanup-tempfolders
    }
    ".+Server.+2012 [R2]{2}.+" {
        Write-Host "Found Windows Server 2012 R2"
        Copy-CleanmgrFiles
        Set-CleanMgrRegKeys
        Run-CleanMgr
        DISM-Clean_SuperSeded
        DISM-Clean_StartComponentCleanup
        Cleanup-tempfolders
    }
}
$AfterScriptFreeDiskSpace = Get-FreeDiskSpace
$DeltaDiskSpace = "{0:N2}" -f ($AfterScriptFreeDiskSpace - $BeforeScriptFreeDiskSpace)
$EndTime = Get-Date
$ts = New-TimeSpan $StartTime $EndTime
if ($ts.Totalminutes -lt 1) {
    $ElapsedTime = "$('{0:N2}' -f $ts.TotalSeconds) seconds"
}
else {
    $ElapsedTime = "$('{0:N2}' -f $ts.TotalMinutes) minutes"
}
Write-Host "---------------------------------------------------------------"
Write-Host "Free disk space before clean: $BeforeScriptFreeDiskSpace GB."
Write-Host "Free disk space after clean: $AfterScriptFreeDiskSpace GB."
Write-Host "---------------------------------------------------------------"
Write-Host "Total space cleaned: $DeltaDiskSpace GB."
Write-Host "---------------------------------------------------------------"
Write-Host "Time Elapsed: $ElapsedTime"
Write-Host "---------------------------------------------------------------"
