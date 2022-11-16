<#
    .SYNOPSIS
        Code to call various modules/script for windows logging
    .DESCRIPTION
        Code to call various modules/script for windows logging
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 10 June 2022
        Modified By: Anil Kumar
        Modified Date: 20 June 2022
#>

param (
    $vmName,    
    $vmResourceGroupName
)

try
{
    # Install modules necessary for DSC configuration
    # First install the NuGet package provider
    if(-not (Get-PackageProvider NuGet -ListAvailable -ErrorAction Ignore)){
        # Below 2 lines are for offline download (without dependancy on internet)
        Expand-Archive .\NuGet.zip -DestinationPath $env:ProgramFiles\PackageManagement\ReferenceAssemblies\
        Install-PackageProvider NuGet -Force

        # Below code line is for online download (having dependancy on internet connection)
        #Install-PackageProvider NuGet -Force
    }

    # Install ComputerManagement DSC PS modules if not already installed
    if(-not (Get-Module ComputerManagementDsc -ListAvailable -ErrorAction Ignore)){
        # Below line is for offline download (without dependancy on internet)
        Expand-Archive .\ComputerManagementDsc.zip -DestinationPath C:\Windows\system32\WindowsPowerShell\v1.0\Modules\ComputerManagementDsc
        Import-Module ComputerManagementDsc -Force # Import-module when using offline zip files (without dependency on internet)

        # Below code line is for online download (having dependancy on internet connection) 
        #Install-Module ComputerManagementDsc -Force # When downloading from internet
    }


    # Implement the max size for windows logs
    & .\Set_Size_Windows_Logs.ps1

}
catch
{
    Write-Error 'Error in calling windows log modules' $_.Exception.Message
}
