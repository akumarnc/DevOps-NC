<#
    .SYNOPSIS
        Code to remove Custom Script Extension on Windows Virtual Machine 2019.
    .DESCRIPTION
        This is script file performs below tasks:
        a.) Receives parameter from Github action workflow.
        b.) Calls 'Remove-AzVMExtension' command to remove Custom Script Extension 
            from the vm in a loop for all the VMs configured.
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 17 June 2022
        Modified By: Anil Kumar
        Modified Date: 20 June 2022
#>

param (
        $virtualMachineName,
        $virtualMachineResourceGroup,
        $cseName
)


Write-Host "PowerShell Remove Custom Script Extension processed a request"

$vm_name                        = $null
$resource_group_name            = $null
$location                       = $null
$custom_script_extension_name   = $null

Write-Host "Variable initialization complete"

# # Read the JSON file for Windows Logging configurations
# $VirtualMachinesFile = Get-Content -Raw -Path .\VirtualMachineConfig.json
# $psObjVirtualMachinesFile = ConvertFrom-Json $VirtualMachinesFile

# $psObjVirtualMachinesFile | Select-Object -Property VMs

try {
    if(!($null -eq $virtualMachineName)) {

        # Write-Host 'Values received from VM JSON File and is not null'

        # Write-Host "VM Count :" $psObjVirtualMachinesFile.VMs.VM.count

        Write-Host "----------------------------------"

        # Logic to loop and assign the vn name, location name and resource group name of various VMs
        # for calling the custom script extension.
        #for($i=0; $i -lt $psObjVirtualMachinesFile.VMs.VM.count; $i++) {

            Write-Host 'START: Remove Custom Script Extension command'

            $vm_name = $virtualMachineName
            #$location = $psObjVirtualMachinesFile.VMs.VM[$i].Location
            $resource_group_name = $virtualMachineResourceGroup
            $custom_script_extension_name = $cseName

            Write-Host "VM Name :" $vm_name
            #Write-Host "VM Location :" $location
            Write-Host "VM Resource Group :" $resource_group_name
            Write-Host "Custom Extension Script Name :" $custom_script_extension_name

            Remove-AzVMExtension -ResourceGroupName $resource_group_name `
                -VMName $vm_name `
                -Name $custom_script_extension_name `
                -Force

            Write-Host 'ENDSTART: Remove Custom Script Extension command' -ForegroundColor Blue

            Write-Host "----------------------------------"
        #}
    }
    else {
        Write-Host 'Values not received from VM JSON file and is null' -ForegroundColor Magenta
    }
}
catch {
    Write-Error 'Error in executing Custom Script Extension' $_.Exception.Message
}



