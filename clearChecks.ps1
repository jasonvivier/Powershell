$apikey="ff6d17322d2237e1905a06306589ce17"


$getchecks="https://systemmonitor.us/api/?apikey=$apikey&service=list_failing_checks"

Invoke-WebRequest $getchecks -OutFile checks.xml

[xml]$checks = Get-Content checks.xml

$checkid = $checks.Result.Items.Client.Site.Workstations.Workstation.failed_checks.check.checkid
$checkdetail = $checks.Result.Items.Client.Site.Workstations.Workstation.failed_checks.check.description.InnerText

$checkid_str = $checkid
$checkdetail_str = $checkdetail


$details = New-Object PSObject -Property @{

    CheckID = $checkid_str
    CheckDetail = $checkdetail_str

    }



$properties = @{ID=''; Description = ''; Dummy = 'Default'}
$objectTemplate = New-Object -TypeName PSObject -Property $properties

$checklist = $checkid_str |
    ForEach-Object {
        $groupID = $_
        $checkdetail_str | ForEach-Object {
            $userDesc = $_

         $objectCurrent = $objectTemplate.PSObject.Copy()
         $objectCurrent.ID = $groupID
         $objectCurrent.Description = $userDesc
         $objectCurrent
        }
    }

$selectid = $checklist | Where-Object {$_.Description -eq "Vulnerability Check"} | Select-Object ID | Out-File ids.txt


Get-Content ids.txt | ForEach-Object {

$inputid = $_

Invoke-WebRequest "https://systemmonitor.us/api/?apikey=$apikey&service=clear_check&checkid=$inputid"

} 
