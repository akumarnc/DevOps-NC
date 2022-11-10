<#
    .SYNOPSIS
        Execute Custom Script Extension on a Windows VM.
    .DESCRIPTION
        Execute Custom Script Extension on a Windows VM.
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 10 Nov 2022
        Modified By: Anil Kumar
        Modified Date: 10 Nov 2022
#>

# Input bindings passed in param block.
param (
        $storageAccountNamePrefix,
        $storageContainerNamePrefix,
        $rgNameStorageAccount,
        $rgLocationStorageAccount,
        $repoRelativeUrl,
        $nsgInternetRuleNamePrefix,
        $nsgAzureCloudRuleNamePrefix
)

#Code to import the PS modules
$currentPath = Get-Location
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/CreateResourceGroup.psm1
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/CreateStorage.psm1
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/UploadFilesToBlobStorage.psm1
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/IdentifyVirtualMachineOSName.psm1
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/ManageNetworkSecurityRules.psm1
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/ModifyServiceEndPoints.psm1


Write-Host "Executing Custom Script Extension on Windows Server processed a request"

$vm_name                        = $null;
$vm_resource_group_name         = $null;
$vm_rg_location                 = $null;
$custom_script_extension_name   = $null;
$sourceUploadFolderPath         = $null;
$fileUri                        = @()
$file_name                      = $null;
$strFileUris                    = $null;

Write-Host 'Upload Source Path for Hardeining Scripts :' $sourceUploadFolderPath

Write-Host "Variable initialization complete"

# Read the JSON file for Windows Logging configurations
$virtualMachinesJSON = Get-Content -Raw -Path .\Config.json

# Convert the virtual machine (JSON) formatted string to a custom PSCustomObject object 
$virtualMachines = ConvertFrom-Json $virtualMachinesJSON

$virtualMachines | Select-Object -Property VMs

try {

    if(
        !($null -eq $storageAccountNamePrefix) -and
        !($null -eq $storageContainerNamePrefix) -and 
        !($null -eq $rgNameStorageAccount) -and 
        !($null -eq $rgLocationStorageAccount) -and 
        !($null -eq $repoRelativeUrl)
    ) {

        if(!($null -eq $virtualMachines)) {

            Write-Host 'Values received from VM JSON File and is not null' -ForegroundColor Green
            Write-Host "VM Count :" $virtualMachines.VMs.VM.count

            # Code to make the UI log print more organized
            Write-Host "--------------------------------------------------------------------------------------------------------------------------------------"

            Write-Host "START: Create a single Resource Group for all Storage Accounts"
            # Call 'CreateResourceGroup' PS module to create Resource Group if it does not exists
            $resourceGroupForStorageAccounts = CreateResourceGroup -rgName $rgNameStorageAccount -rgLocation $rgLocationStorageAccount

            Write-Host "Resource Group for Storage Account from Module :" $resourceGroupForStorageAccounts.name
            Write-Host "END: Create a single Resource Group for all Storage Accounts"

            if(!($null -eq $resourceGroupForStorageAccounts)) {
            # Logic to loop and assign the vn name, location name and resource group name of various VMs (string containing VM details) 
            # for calling the custom script extension.
                for($counterVM=0; $counterVM -lt $virtualMachines.VMs.VM.count; $counterVM++) {
                    
                    Write-Host -Separator `n
                    Write-Host "##############################################################################################################################"
                    Write-Host "START: Executing Hardening for VM :" $virtualMachines.VMs.VM[$counterVM].Name
                    Write-Host "##############################################################################################################################"

                    $vm_name = $virtualMachines.VMs.VM[$counterVM].Name
                    $vm_rg_location = $virtualMachines.VMs.VM[$counterVM].Location
                    $vm_resource_group_name = $virtualMachines.VMs.VM[$counterVM].RG
                    $custom_script_extension_name = "cse-hardening-"+$vm_name

                    # Generate the names of storage account & storage container dynamically
                    $randomNumber = Get-Random
                    $storageAccountName = $storageAccountNamePrefix+$randomNumber+$counterVM
                    $storageAccountName = ($storageAccountName -replace "[^a-zA-Z0-9]").ToLower()
                    
                    $storageContainerName = $storageContainerNamePrefix+'-'+$randomNumber+'-'+$counterVM
                    $storageContainerName = ($storageContainerName -replace "[^a-zA-Z0-9]").ToLower()

                    # Sleep further processing for 15 second as sometimes it says RG not found even though it is created.
                    Start-Sleep -Seconds 15

                    
                    $strFileUris = @(
                            "https://$storageAccountName.blob.core.windows.net/$storageContainerName/Logging_Settings_AllModules.ps1",
                            "https://$storageAccountName.blob.core.windows.net/$storageContainerName/Set_Size_Windows_Logs.ps1",
                            "https://$storageAccountName.blob.core.windows.net/$storageContainerName/Logging_Config.json",
                            "https://$storageAccountName.blob.core.windows.net/$storageContainerName/nuget.zip",
                            "https://$storageAccountName.blob.core.windows.net/$storageContainerName/ComputerManagementDsc.zip"
                    );
                    
                    $sourceUploadFolderPath = "$repoRelativeUrl/Scripts"
                    $file_name = "Logging_Settings_AllModules.ps1"

                    # Step 2: Call the 'CreateStorage' PS module for creating storage account the VM
                    $storage_account = CreateStorage -storageAccountName $storageAccountName -storageContainerName $storageContainerName -rgNameStorageAccount $rgNameStorageAccount -rgLocationStorageAccount $rgLocationStorageAccount
                    if(!($null -eq $storage_account)) {
                        Write-Host "Created Storage Account ID from module :" $storage_account.Id
                        Write-Host "Created Storage Account name from module :" $storage_account.Name

                        # Step 3: Call the 'UploadFilesToBlobStorage' PS module for uploading Hardening scripts to Blob Storage
                        $blobUploadStatus = UploadFilesToBlobStorage -storageAccountName $storageAccountName -storageContainerName $storageContainerName -rgNameStorageAccount $rgNameStorageAccount -rgLocationStorageAccount $rgLocationStorageAccount -sourceUploadFolderPath $sourceUploadFolderPath
                        if($true -eq $blobUploadStatus) {
                            Write-Host 'Blob Upload Status from module :' $blobUploadStatus

                            # Step 4: Add the 'Deny Internet Access' network security rule on VM's NSG by calling 'ManageNetworkSecurityRule' PS module
                            $nsgInternetRuleName = $nsgInternetRuleNamePrefix+'-'+$vm_name
                            $nsgAzureCloudRuleName = $nsgAzureCloudRuleNamePrefix+'-'+$vm_name

                            # If $networkSecurityRuleType = 1, then network security rule is added
                            $networkSecurityRuleType = 1
                            $networkSecurityRuleCreationStatus = ManageNetworkSecurityRules -networkSecurityRuleType $networkSecurityRuleType -nsgInternetRuleName $nsgInternetRuleName -nsgAzureCloudRuleName $nsgAzureCloudRuleName -vmName $vm_name -vmResourceGroupName $vm_resource_group_name
                            if(!($null -eq $networkSecurityRuleCreationStatus)) {

                                # Step 5: Call the 'ModifyServiceEndPoints' PS module for adding / configuring service endpoints
                                # If $-serviceEndPointsRuleCleanup = 0, then service endpoint is added / configured
                                $PreExistingServiceEndPoints = ModifyServiceEndPoints -vmName $vm_name -vmResourceGroupName $vm_resource_group_name -vmRGLocation $vm_rg_location -tempStorageAccount $storageAccountName -tempStorageAccountRGName $rgNameStorageAccount -serviceEndPointsRuleCleanup 0
                                #Write-Host "Added / Configured Microsoft.Storage service endpoints for hardening script execution"

                                #Write-Host "Pre-existing Service Endpoints string :" $PreExistingServiceEndPoints

                                if(!($null -eq $PreExistingServiceEndPoints)) {

                                    # Write-Host "Pre-existing service endpoints is not null"
                                    # Write-Host "Service Endpoint added / configured for the VM $vm_name and Storage Account $storageAccountName"

                                    # Step 6: Call the 'Custom Script Extension' command on the VM for hardening
                                    Write-Host "******************************************************************************************************************************"
                                    Write-Host "STEP 6: Call the 'Custom Script Extension' command VM hardening"
                                    Write-Host "******************************************************************************************************************************"

                                    Write-Host "Custom Extension Script Name :" $custom_script_extension_name
                                    Write-Host "VM Name :" $vm_name
                                    Write-Host "VM Location :" $vm_rg_location
                                    Write-Host "VM Resource Group :" $vm_resource_group_name

                                    try {

                                        $StorageKey = (Get-AzStorageAccountKey -ResourceGroupName $rgNameStorageAccount -Name $storageAccountName)| Where-Object {$_.KeyName -eq "key1"}

                                        Write-Host 'Str File Uris ::' $strFileUris

                                        $fileUri = $strFileUris

                                        $settings = @{
                                            "fileUris" = $fileUri
                                        };

                                        $protectedSettings = @{
                                            "storageAccountName" = $storageAccountName;
                                            "storageAccountKey" = $StorageKey.Value;
                                            "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File " +$file_name
                                        };

                                        Set-AzVMExtension -ResourceGroupName $vm_resource_group_name `
                                            -Location $vm_rg_location `
                                            -VMName $vm_name `
                                            -Name $custom_script_extension_name `
                                            -Publisher "Microsoft.Compute" `
                                            -ExtensionType "CustomScriptExtension" `
                                            -TypeHandlerVersion "1.10" `
                                            -Settings $settings `
                                            -ProtectedSettings $protectedSettings
                                    }
                                    catch {
                                        Write-Error 'Error in executing Custom Script Extension for VM ' $vm_name ' :'  $_.Exception.Message
                                    }
                                    
                                }
                                else {
                                    Write-Host "Pre-existing service endpoints is null"
                                    Write-Host "Error in configuring Service Endpoint for the VM $vm_name and Storage Account $storageAccountName"
                                }
                            }
                            else {
                                Write-Host "Error in configuring NSG rules for the VM $vm_name"
                            }

                            # Step 7: Remove the 'Deny Internet Access' network security rule on VM's NSG by calling 'ManageNetworkSecurityRule' PS module
                            # If $networkSecurityRuleType = 0, then network security rule is removed
                            $networkSecurityRuleType = 0
                            $networkSecurityRuleCreationStatus = ManageNetworkSecurityRules -networkSecurityRuleType $networkSecurityRuleType -nsgInternetRuleName $nsgInternetRuleName -nsgAzureCloudRuleName $nsgAzureCloudRuleName -vmName $vm_name -vmResourceGroupName $vm_resource_group_name
                            Write-Host "Status of Network Security Removal :" $networkSecurityRuleDeletionStatus

                            # Step 8: Call the 'ModifyServiceEndPoints' PS module for rollback (deleting/cleanup) of service endpoint added via this workflow / script
                            # If $-serviceEndPointsRuleCleanup = 1, then service endpoint is rolled-back / deleted / cleaned.
                            # $PreExistingServiceEndPoints object conatin the list of service endpoinst which needs to be rolled-back

                            $storageServiceEndpointsExists = $false
                            foreach ($PreExistingServiceEndPoint in $PreExistingServiceEndPoints) {
                                Write-Host "Pre-existing Service Endpoint Name received in main CSE script :" $PreExistingServiceEndPoint.Service
                                if('Microsoft.Storage' -eq $PreExistingServiceEndPoint.Service){
                                    $storageServiceEndpointsExists = $true
                                    break;
                                }
                            }

                            # Code to call the ModifyServiceEndPoints module for rollback of service endpoints, only if modification were done as part of this workflow / script
                            if($false -eq $storageServiceEndpointsExists) {
                                Write-Host "Calling ModifyServiceEndPoints module to rollback service endpoints as it added Microsoft.Storage"
                                ModifyServiceEndPoints -vmName $vm_name -vmResourceGroupName $vm_resource_group_name -vmRGLocation $vm_rg_location -tempStorageAccount $storageAccountName -tempStorageAccountRGName $rgNameStorageAccount -serviceEndPointsRuleCleanup 1 -exitingServiceEndpoints $PreExistingServiceEndPoints
                            }
                            else {
                                Write-Host "Not calling ModifyServiceEndPoints module to rollback as Microsoft.Storage service endpoints already existed"
                            }
                        }
                        else {
                            Write-Host 'Error uploading hardening scripts to storage account. Hardeining failed for VM :' $vm_name 
                        }
                    }
                    else {
                        Write-Host 'Error creating temporary storage account. Hardeining failed for VM :' $vm_name 
                    }

                    Write-Host "##############################################################################################################################"
                    Write-Host "END: Executing Hardening for VM :" $virtualMachines.VMs.VM[$counterVM].Name
                    Write-Host "##############################################################################################################################"
                    Write-Host -Separator `n
                }
            } else {
                Write-Error "Error in creating the temporary resource group. Hardening failed for all VMs."
            }
        } else {
            Write-Host "Error in fetching VM details from JSON file. Hardening failed for all VMs."
        }
    } else {
        Write-Host "Error in receiving parameters from Pipeline / main Custom Script extension. Hardening failed for all VMs."
    }
}
catch {
    Write-Error "Error in executing Custom Script Extension. Hardeining failed for all VMs :" $_.Exception.Message
}
