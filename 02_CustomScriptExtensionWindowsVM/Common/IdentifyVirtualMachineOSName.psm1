<#
    .SYNOPSIS
        Code to Create Private DNS Zone.
    .DESCRIPTION
        Code to Create Private DNS Zone.
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 01 July 2022
        Modified By: Anil Kumar
        Modified Date: 01 July 2022
#>
function IdentifyVirtualMachineOSName {
    param (
        [string] $vmName,
        [string] $vmResourceGroupName
    )

    $virtualMachineOSName = $null

    Write-Host "******************************************************************************************************************************"
    Write-Host "STEP 1 : Identify Virtual Machine SKU ps module received a request"
    Write-Host "******************************************************************************************************************************"

    Write-Host "VM name received from Pipeline :" $vmName
    Write-Host "VM RG name received from Pipeline :" $vmResourceGroupName

    try {
        if(
            !($null -eq $vmName) -and
            !($null -eq $vmResourceGroupName)
        ) {
            Write-Host "VM name & resource group is not null"

            $vm = Get-AzVM -ResourceGroupName $vmResourceGroupName -Name $vmName -Status
            $virtualMachineOSName = $vm.OsName
        }

        Write-Host "VM SKU OsName :" $virtualMachineOSName
        return $virtualMachineOSName
    }
    catch {
        Write-Error 'Module Error in Identifying Virtual Machine OS Name' $_.Exception.Message
    }
}
