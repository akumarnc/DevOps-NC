<#
    .SYNOPSIS
        Solution & code for Hardening Windows Virtual Machine server.
    .DESCRIPTION
        
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 10 Nov 2022
        Modified By: Anil Kumar
        Modified Date: 10 Nov 2022
#>

# Input bindings passed in param block.
param (
        $virtualMachineName,
        $virtualMachineLocation,
        $virtualMachineResourceGroup,
        $storageAccountNamePrefix,
        $storageContainerNamePrefix,
        $rgNameStorageAccount,
        $rgLocationStorageAccount,
        $nsgInternetRuleNamePrefix,
        $nsgAzureCloudRuleNamePrefix,
        $repoRelativeUrl,
        $cseName
)

#Code to import the PS modules
$currentPath = Get-Location
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/CreateResourceGroup.psm1
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/CreateStorage.psm1
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/UploadFilesToBlobStorage.psm1
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/ManageNetworkSecurityRules.psm1
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/ModifyServiceEndPoints.psm1
Import-Module $currentPath/02_CustomScriptExtensionWindowsVM/Common/IdentifyVirtualMachineOSName.psm1

Write-Host "Custom Script Extension processed a request"

Write-Host "Relative Repo Url : " $repoRelativeUrl


$vm_name                        = $null;
$vm_resource_group_name         = $null;
$vm_rg_location                 = $null;
$custom_script_extension_name   = $null;
$sourceUploadFolderPath         = $null;
$fileUri                        = @()
$file_name                      = $null;
$strFileUris                    = $null;

Write-Host 'Upload Source Path for Scripts :' $sourceUploadFolderPath

Write-Host "Variable initialization complete"

try {
    if(
        !($null -eq $virtualMachineName) -and
        !($null -eq $repoRelativeUrl)
    ) {
        Write-Host "VM name received from pipeline :" $virtualMachineName
        Write-Host "VM location received from pipeline :" $virtualMachineLocation
        Write-Host "VM resource group received from pipeline :" $virtualMachineResourceGroup
   
        $randomValue = Get-Random
        $rgNameStorageAccount = $rgNameStorageAccount+'-'+$randomValue

        # Set the output variable to be accessible from Github runner
        Write-Output "::set-output name=_rgName::$rgNameStorageAccount"
        
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
            #for($counterVM=0; $counterVM -lt $virtualMachines.VMs.VM.count; $counterVM++) {
                
                Write-Host -Separator `n
                Write-Host "##############################################################################################################################"
                #Write-Host "START: Executing Hardening for VM :" $virtualMachines.VMs.VM[$counterVM].Name
                Write-Host "##############################################################################################################################"

                $vm_name = $virtualMachineName
                $vm_rg_location = $virtualMachineLocation
                $vm_resource_group_name = $virtualMachineResourceGroup
                $custom_script_extension_name = $cseName

                Write-Output 'Custom Script Extension Name received from Pipeline :' $custom_script_extension_name

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

                $sourceUploadFolderPath = "$repoRelativeUrl/02_CustomScriptExtensionWindowsVM/Scripts"

                $file_name = "Logging_Settings_AllModules.ps1"
                    
                    
                # Step 1: Call the 'CreateStorage' PS module for creating storage account the VM
                $storage_account = CreateStorage -storageAccountName $storageAccountName -storageContainerName $storageContainerName -rgNameStorageAccount $rgNameStorageAccount -rgLocationStorageAccount $rgLocationStorageAccount
                if(!($null -eq $storage_account)) {
                    Write-Host "Created Storage Account ID from module :" $storage_account.Id

                    # Step 2: Call the 'UploadFilesToBlobStorage' PS module for uploading Hardening scripts to Blob Storage
                    $blobUploadStatus = UploadFilesToBlobStorage -storageAccountName $storageAccountName -storageContainerName $storageContainerName -rgNameStorageAccount $rgNameStorageAccount -rgLocationStorageAccount $rgLocationStorageAccount -sourceUploadFolderPath $sourceUploadFolderPath
                    if($true -eq $blobUploadStatus) {
                        Write-Host 'Blob Upload Status from module :' $blobUploadStatus

                        # Step 4: Add the 'Deny Internet Access' network security rule on VM's NSG by calling 'ManageNetworkSecurityRule' PS module
                        $nsgInternetRuleName = $nsgInternetRuleNamePrefix+'-'+$vm_name
                        $nsgAzureCloudRuleName = $nsgAzureCloudRuleNamePrefix+'-'+$vm_name

                        # Step 6: Call the 'Custom Script Extension' command on the VM for hardening
                        Write-Host "******************************************************************************************************************************"
                        Write-Host "STEP 4: Call the 'Custom Script Extension' on Windows VM :" $vm_name
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
                        Write-Host 'Error uploading scripts to storage account for vm :' $vm_name 
                    }
                }
                else {
                    Write-Host 'Error creating temporary storage account. Hardeining failed for VM :' $vm_name 
                }

                Write-Host "##############################################################################################################################"
                Write-Host "END: Executing Hardening for VM :" $vm_name
                Write-Host "##############################################################################################################################"
        }
        else {
            Write-Error "Error in creating the temporary resource group for storage account. Hardening failed for all VMs."
        }
    }
    else {
        Write-Host "Parameter values received from github actions workflow is null. Hardening failed for all VMs."
    }
}
catch {
    Write-Error "Error in executing Custom Script Extension. Hardeining failed for all VMs :" $_.Exception.Message
}
