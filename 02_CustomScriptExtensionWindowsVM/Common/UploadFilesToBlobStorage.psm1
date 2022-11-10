<#
    .SYNOPSIS
        Code to upload files to Storage Blob Container.
    .DESCRIPTION
        Code to upload files within a folder to Storage Blob Container using SAS.
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 24 June 2022
        Modified By: Anil Kumar
        Modified Date: 30 June 2022
#>
function UploadFilesToBlobStorage {
    param (
        $storageAccountName,
        $storageContainerName,
        $rgNameStorageAccount,
        $rgLocationStorageAccount,
        $sourceUploadFolderPath
    )

    try {
        # Variables for SAS token
        $permissions        = "racwdl"
        $protocol           = "HttpsOnly"
        $blobFileUris       = @()
        $blobUploadStatus   = $false 

        #Write-Host ""
        Write-Host "******************************************************************************************************************************"
        Write-Host "STEP 3 : Blob Storage Upload files ps module received a request"
        Write-Host "******************************************************************************************************************************"

        Write-Host 'Upload File Source Folder Path :' $sourceUploadFolderPath
        Write-Host "Upload File Storage Account Name received from Pipeline :" $storageAccountName
        Write-Host "Upload File Storage Container Name received from Pipeline :" $storageContainerName
        Write-Host "Upload File RG Name for the Storage Account received from Pipeline :" $rgNameStorageAccount
        Write-Host "Upload File RG Location for the Storage Account received from Pipeline  :" $rgLocationStorageAccount

        if(!$null -eq $storageAccountName) {

            # Use the storage SAS token for authentication
            $StorageKey = (Get-AzStorageAccountKey -Name $storageAccountName -ResourceGroupName $rgNameStorageAccount).value[0]
            Write-Host 'Upload File Storage Key Length :' $StorageKey.Length

            # Get storage context, using key as credential
            $ctxStorageAccount = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storagekey
            Write-Host 'Upload File Storage Account Context :' $ctxStorageAccount.StorageAccountName

            # Create SAS token to the storage container to upload files from GitHub to Blob Storage.
            $sas = New-AzStorageAccountSASToken -Context $ctxStorageAccount -Service Blob,File,Table,Queue -ResourceType Service,Container,Object -Permission $permissions -Protocol $protocol
            Write-Host 'Upload File Storage Account SAS Length :' $sas.Length

            # Loop through all the files within the hardening script folder
            Get-ChildItem –Path $sourceUploadFolderPath |
            Foreach-Object {
                try {
                    $file = $_.Name
            
                    $headers = @{
                        'x-ms-blob-type' = 'BlockBlob'
                    }

                    # Upload files to Blob container
                    $bloburi = "https://$storageAccountName.blob.core.windows.net/$storageContainerName/$file$sas"
                    #Write-Host 'Upload File Blob Uri :' $bloburi
                    
                    Invoke-WebRequest -Uri $bloburi -Method Put -Headers $headers -InFile "$sourceUploadFolderPath/$file"
                    
                    Write-Host 'Uploaded Hardening Filename or Foldername :' $file

                    $blobUploadStatus = $true
                }
                catch {
                    $blobUploadStatus = $false
                    Write-Error 'Error in uploading :' $file ' file to Blob container :' $storageContainerName
                }
            }
        }
        
    }
    catch {
        Write-Error 'Error in module upload files to Blob container :' $_.Exception.Message 
    }

    # Return Blob Upload status to caller
    return $blobUploadStatus
}

  