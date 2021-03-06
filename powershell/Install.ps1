# cd C:\Users\Joel\Projects\PowerShell\Win32Window\bin\Debug
param($dllfile=$(Read-Host "Please specify the path of a snapin assembly"),[switch]$Add)
$Local:ErrorActionPreference = "Inquire"
$InstallUtil = Join-Path $([System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()) InstallUtil.exe

#{ ## lots of input argument checking ...
   if(-not(Test-Path $InstallUtil)) {
      Throw (new-object IO.FileNotFoundException "Couldn't find InstallUtil.exe to install the snapin")
   }
   if(-not(Test-Path $dllfile)) {
      Throw (new-object IO.FileNotFoundException "Couldn't find '$dllFile' -- Please specify the path to an existing assembly")
   }

   [IO.FileInfo]$assembly = Resolve-Path $dllfile | Get-ChildItem

   if($assembly.Extension -ne ".dll") {
      Throw (new-object IO.FileNotFoundException "FileType '$($assembly.Extension)' not accepted -- Please specify a Dll file")
   }
   Write-Verbose $assembly
   
   $installfile = $(Join-Path $assembly.Directory.FullName $assembly.BaseName)+"_installed.dll"
   $uninstalled = $(Join-Path $assembly.Directory.FullName $assembly.BaseName)+"_uninstall-failure.dll"

#}

# Uninstall if necessary
if(Test-Path $installfile) {
	&$InstallUtil /u /ShowCallStack $installfile
	if($?) {
		Remove-Item $installfile
      if(!$?) {
         if(Test-Path $uninstalled) { Remove-Item $uninstalled }
         Move-Item $installfile $uninstalled
         Write-Host "Uninstall Successful" -Fore Green 
         Write-Error "Can't delete yet. File moved to $uninstalled"
      }
	} else {
		Move-Item $installfile $uninstalled
		Write-Error "Problem Uninstalling. File moved to $uninstalled"
	}
}
Copy-Item $assembly $installfile

&$InstallUtil /ShowCallStack  $installfile

if($Add) {
   Get-PsSnapin -Registered | ? {$_.ModuleName -eq $installfile} | Add-PsSnapin -Pass | %{ Get-Command -PsSnapin $_ }
}