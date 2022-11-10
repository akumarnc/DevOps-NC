<#
    .SYNOPSIS
        Code to Storage Account & Blob Container.
    .DESCRIPTION
        Code to Storage Account & Blob Container for storing the hardening scripts.
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 22 June 2022
        Modified By: Anil Kumar
        Modified Date: 22 June 2022
#>
function CreateResourceGroup {
    param (
        $rgName,
        $rgLocation
    )

    #Write-Host ""
    Write-Host "******************************************************************************************************************************"
    Write-Host "Resource Group creation ps module received a request"
    Write-Host "******************************************************************************************************************************"

    Write-Host "RG name received from Pipeline :" $rgName
    Write-Host "RG location received from Pipeline :" $rgLocation

    $resourceGroup = $null
    
    try {

        if(
            !($null -eq $rgName) -and
            !($null -eq $rgLocation)
        ) {
            $resourceGroup = New-AzResourceGroup -Name $rgName -Location $rgLocation -Force
            if(!($null -eq $resourceGroup)) {
                Write-Host 'Resource Group Created :' $resourceGroup.ResourceGroupName
            }
            else {
                $resourceGroup = $null
                Write-Error 'Error in creating the resource Group'
            }
        }
    }
    catch {
        Write-Error 'Error in creating resource group in module' $_.Exception.Message
    }
    return $resourceGroup
}
  