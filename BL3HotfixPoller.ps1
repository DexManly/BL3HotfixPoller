# Author:        dex_manly (twich handle)                                                                                                                         
# General Info:  This script relies on getting an initial version of the "hotfix" (aka MicroPatch) and then polling every so often to see if the version or contents have change. 
#                To run, I would suggest starting the script early on hotfix day to get your initial version and then keeping it running until you get an update. The script is provided as is.


# Settings
$platform = "steam" # or replace with "epic" depending on your platform
$pollingInterval = 60; # in seconds

$currentHotfixNumber = $null;
$currentHotfixContents = $null;


# Welcome header
echo ""
echo "================================================="
echo "== Borderlands 3 Hotfix Version Poller ($($platform)) =="
echo "==             (Exit with ctrl+c)              =="
echo "================================================="


# main polling loop start
while ($true)
{
    # Make Rest API and get config version number...returns object list of services and we only care about the service called 'micropatch'
    $hotfixMicropatchSection = (Invoke-RestMethod -Uri "https://discovery.services.gearboxsoftware.com/v2/client/$($platform)/pc/oak/verification").services.where({$_.service_name -eq 'micropatch'})
    
    # Keep track of version of micropatch
    $hotfixNumber = $hotfixMicropatchSection.configuration_version
    
    # keep track of micropatch contents in case content changes but version stays the same. (Probably bad patch practice but it could happen)
    $hotfixContents = (ConvertTo-Json $hotfixMicropatchSection.parameters)

    if ($currentHotfixNumber -eq $null) #First poll, find initial patch!
    {
        $currentHotfixNumber = $hotfixNumber
        $currentHotfixContents = $hotfixContents
        echo ("Initial hotfix found!           Detected at: " + [DateTime]::UtcNow.ToString('u') + "(UTC).       Hotfix version: " + $currentHotfixNumber)
    }
    elseif (($currentHotfixNumber -ne $hotfixNumber) -or ($currentHotfixContents -ne $hotfixContents)) #Difference of some sort was found.
    {
        $currentHotfixNumber = $hotfixNumber
        $currentHotfixContents = $hotfixContents
        echo ("Hotfix change detected!         Detected at: " + [DateTime]::UtcNow.ToString('u') + "(UTC).       Hotfix version: " + $currentHotfixNumber)
    }
    else #No change (remove # in line below to show something)
    {
        #echo "No change" #Helpful for debug
    }

    Start-Sleep -Seconds $pollingInterval;
}