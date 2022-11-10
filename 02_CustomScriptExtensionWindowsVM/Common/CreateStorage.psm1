<#
    .SYNOPSIS
        Code to create Storage Account & Blob Container.
    .DESCRIPTION
        Code to create Storage Account & Blob Container for storing the hardening scripts.
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 22 June 2022
        Modified By: Anil Kumar
        Modified Date: 22 June 2022
#>
function CreateStorage {
    param (
        $storageAccountName,
        $storageContainerName,
        $rgNameStorageAccount,
        $rgLocationStorageAccount
    )

    #Write-Host ""
    Write-Host "******************************************************************************************************************************"
    Write-Host "STEP 2 : Storage Account creation ps module received a request"
    Write-Host "******************************************************************************************************************************"

    Write-Host "Storage Account Name received from Pipeline :" $storageAccountName
    Write-Host "Storage Container Name received from Pipeline :" $storageContainerName
    Write-Host "RG Name for the Storage Account received from Pipeline :" $rgNameStorageAccount
    Write-Host "RG Location for the Storage Account received from Pipeline  :" $rgLocationStorageAccount

    if(!$null -eq $storageAccountName) {
        
        $storageAccountObj = New-AzStorageAccount -ResourceGroupName $rgNameStorageAccount -name $storageAccountName -location $rgLocationStorageAccount -skuname Standard_LRS -Kind StorageV2 -MinimumTlsVersion TLS1_2
        if(!($null -eq $storageAccountObj)) {
            Write-Host 'Storage Account created :' $storageAccountObj.Id
            # Use the storage SAS token for authentication, not the connected user.
            
            $StorageKey = (Get-AzStorageAccountKey -Name $storageAccountName -ResourceGroupName $rgNameStorageAccount).value[0]
            if(!($null -eq $StorageKey)) {
                Write-Host 'Storage Account Key fetched'
                # Get storage context, using key as credential
                
                $ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storagekey
                if(!($null -eq $StorageKey)) {
                    Write-Host 'Storage Account context set for container creation'
                    ## Create a container on the storage account
                    New-AzStorageContainer -Name $storageContainerName -Context $ctx
                }
                else {
                    Write-Error 'Error in setting the Storage Account context for container creation'
                }
            }
            else {
                Write-Error 'Error in fetching Storage Account Key'
            }
        }
        else {
            Write-Error 'Error in creating the Storage Account'
        }
        return $storageAccountObj
    }
}
  