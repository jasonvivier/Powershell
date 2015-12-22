##########################################################################
# Shink VHD Files 
# This script is designed to shrink Dynamic VHD files used by products such as Citrix Provisioning Server
# XenApp_Wizard_v1.ps1 script written by Phillip Jones and David Ott
# Version 1.0
# This script is provided as-is, no warrenty is provided or implied.
#
# The author is NOT responsible for any damages or data loss that may occur
# through the use of this script.  Always test, test, test before
# rolling anything into a production environment.
#
# This script is free to use for both personal and business use, however,
# it may not be sold or included as part of a package that is for sale.
#
# A Service Provider may include this script as part of their service
# offering/best practices provided they only charge for their time
# to implement and support.
#
# For distribution and updates go to: http://www.www.p2vme.com
##########################################################################
#Command can either specify a -folderPath arg or a -filePath; If both are provided, only filePath will be used
#PS C:\Users\myers_000\Desktop> .\Shrink_VHD.ps1 -filePath "E:\Hyper-V\Base\Windows7_Ultimate_64\BizTalk 2010.vhd"

Param(
    [string]$folderPath,
    [string]$filePath
)

Function Shrink($vdiskPath)
{
    # Command to mount the VHD file
    $script1 = "select vdisk file=`"$vdiskpath`"`r`nattach vdisk" 

    # Command to assign the drive letter
    $script2 = "select vdisk file=`"$vdiskpath`"`r`nselect part 2`r`nassign letter=$letter"

    # Command to detach VHD
    $script3 = "select vdisk file=`"$vdiskpath`"`r`ndetach vdisk"

    # Dual part command:
    #     Command to re-mount the VHD in read only mode
    #     Command to shrink the VHD using DISKPART
    $script4 = "select vdisk file=`"$vdiskpath`"`r`nattach vdisk readonly`r`ncompact vdisk"

    #
    #
    # Mount the VHD and assign our drive letter after 5 seconds
    $script1 | diskpart
    start-sleep -s 5
    $script2 | diskpart

    # Defrag and optimize the mounted drive
    defrag $letter /U /V /X

    # Unmount the VHD
    $script3 | diskpart

    # Mount the VHD in read-only mode, and compact the virtual disk
    $script4 | diskpart

    # Unmount the VHD
    $script3 | diskpart
}


# The lines below will detect the next legal available drive letter and choose the next available letter  
$letter = [char[]]”DEFGJKLMNOPQRTUVWXY” | ?{!(gdr $_ -ea ‘SilentlyContinue’)} | select -f 1
$letter = $letter + ":"

# Condition to determine if we're compacting a single file or files within a folder
if ($filePath -and (Test-Path $filePath))
{
    Shrink($filePath)
}
else 
{
    if ($folderPath -and (Test-Path $folderPath))
    {
        # Iterate through all vhd files in the folder
        $Dir = get-childitem $folderPath -include *.vhd -name
        foreach ($name in $dir) 
        {
            $vdiskpath = $path + "\" + $name
            Shrink($vdiskpath)
        }
    }
}