<#
    .SYNOPSIS
        Code to delete the resource group.
    .DESCRIPTION
        Code to delete the resource group from current subscription.
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 29 June 2022
        Modified By: Anil Kumar
        Modified Date: 01 July 2022
#>

param (
    $resourceGroupName
)

#Write-Host ""
Write-Host "******************************************************************************************************************************"
Write-Host "Resource Group deletion ps script received a request"
Write-Host "******************************************************************************************************************************"

Write-Host "Resource Group Name received from Pipeline :" $resourceGroupName
try {
    if(!$null -eq $resourceGroupName) {

        Remove-AzResourceGroup -Name $resourceGroupName -Force
    }
}
catch {
    Write-Error 'Error in deleting Resource Group :' $_.Exception.Message
}
  