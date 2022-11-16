<#
    .SYNOPSIS
        Code to Create Private EndPoints.
    .DESCRIPTION
        Code to Create Private EndPoints for Storage Account.
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 15 Aug 2022
        Modified By: Anil Kumar
        Modified Date: 16 Aug 2022
#>
function ModifyServiceEndPoints {
    param (
        [string] $vmName,
        [string] $vmResourceGroupName,
        [string] $vmRGLocation,
        [string] $tempStorageAccount,
        [string] $tempStorageAccountRGName,
        [string] $serviceEndPointsRuleCleanup,
        [Parameter(Mandatory=$false)] $exitingServiceEndpoints
    )

    $SvcEndPoints = @()
    [String]$strExistingServiceEndpoints = ""

    if(0 -eq $serviceEndPointsRuleCleanup) {
        $stepNumberHardening = 5
    }
    else {
        $stepNumberHardening = 8
    }

    #Write-Host ""
    Write-Host "******************************************************************************************************************************"
    Write-Host "STEP $stepNumberHardening : Service Endpoints modification ps module received a request"
    Write-Host "******************************************************************************************************************************"

    Write-Host "VM name received from Pipeline :" $vmName
    Write-Host "VM RG name received from Pipeline :" $vmResourceGroupName
    Write-Host "VM RG location name received from Pipeline :" $vmRGLocation
    Write-Host "Temporary Storage Account name received from Pipeline :" $tempStorageAccount
    Write-Host "Service EndPoint Adding / Cleanup value received from Pipeline :" $serviceEndPointsRuleCleanup
    Write-Host ""
    #Write-Host "Service Endpoints configuration type (add - 1 / remove - 0) received from Pipeline :" $serviceEndpointsConfigurationType

    try {
        if(
            !($null -eq $vmName) -and
            !($null -eq $vmResourceGroupName) -and
            !($null -eq $vmRGLocation)
        ) {
                
            #Get the VM instance
            $vm = Get-AzVM -ResourceGroupName $vmResourceGroupName -Name $vmName
            Write-Host 'VM Name :'  $vm.Name
            if(!($null -eq $vm)) {
                Write-Host "VM Object created from vm name"

                # Get the VM NIC instance
                $vmnic = ($vm.NetworkProfile.NetworkInterfaces.id).Split('/')[-1]
                if(!($null -eq $vmnic)) {
                    Write-Host 'VM NIC Text Name :'  $vmnic

                    # Get the VM NIC information
                    $vmnicinfo = Get-AzNetworkInterface -Name $vmnic
                    if(!($null -eq $vmnicinfo)) {
                        Write-Host 'VM NIC Name :'  $vmnicinfo.Name

                        # Get the subnet and the vNet name
                        $subnet = $vmnicinfo.IpConfigurations.subnet
                        if(!($null -eq $subnet)) {
                            Write-Host 'VM subnet object :'  $subnet

                            $subnet_name = ($subnet.Id).split('/')[-1]
                            if(!($null -eq $subnet_name)) {
                                Write-Host 'VM Subnet Name :'  $subnet_name
                                
                                $vnet = Get-AzVirtualNetwork -ResourceGroupName $vmResourceGroupName -Name ($vmnicinfo.IpConfigurations.subnet.Id -split '/')[-3]
                                if(!($null -eq $vnet)) {
                                    Write-Host 'VM VNet Object :' $vnet
                                    Write-Host 'VM VNet name :' $vnet.Name

                                    $subnetConfig = Get-AzVirtualNetworkSubnetConfig -Name $subnet_name -VirtualNetwork $vnet
                                    if(!($null -eq $subnetConfig)) {

                                        $SvcEndPoints = $subnetConfig.ServiceEndpointText | ConvertFrom-Json -AsHashtable
                                        $storageSvcEndPointExists = $false
                                        
                                        $exitingServiceEndpointsOptimized = @()
                                        

                                        # This is the scenario of adding/configuring 'Microsoft.Storage' service endpoint configuration
                                        if(0 -eq $serviceEndPointsRuleCleanup) {
                                            # Code to loop through all the existing Service Endpoints and validate is 'Microsoft.Storage' exists or not.
                                            foreach ($SvcEndpoint in $SvcEndPoints) {
                                                #Write-Host "Pre-existing Service Endpoints :" $SvcEndpoint
                                                Write-Host "Pre-existing Service Endpoint Name :" $SvcEndpoint.Service
                                                
                                                $strExistingServiceEndpoints += "'"
                                                $strExistingServiceEndpoints += $SvcEndpoint.Service
                                                $strExistingServiceEndpoints += "'"
                                                $strExistingServiceEndpoints += ","
                                                
                                                if('Microsoft.Storage' -eq $SvcEndpoint.Service)
                                                {
                                                    Write-Host "Microsoft.Storage service endpoint already exists !!!"
                                                    $storageSvcEndPointExists = $true
                                                }
                                            }

                                            if($false -eq $storageSvcEndPointExists)
                                            {
                                                # START: Create a Virtual Service endpoint on the subnet
                                                Write-Host "Configure a Service Endpoint 'Microsoft.Storage' to the VM subnet."
                                                $serviceEndPointsArray = @()
                                                foreach ($SvcEndpoint in $SvcEndPoints) {
                                                    $serviceEndPointsArray += $SvcEndpoint.Service
                                                }
                                                $serviceEndPointsArray += 'Microsoft.Storage'

                                                # Code to supress the warning message 
                                                Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

                                                $vnetSubParams = @{
                                                    Name            = $subnet_name
                                                    AddressPrefix   = $subnetConfig.AddressPrefix
                                                    VirtualNetwork  = $vnet
                                                    ServiceEndpoint = $serviceEndPointsArray
                                                }
                                                $vnet = Set-AzVirtualNetworkSubnetConfig @vnetSubParams

                                                Write-Host "Persist the updates made to the virtual network > subnet."

                                                # Persist the updates made to the virtual network > subnet.
                                                $vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet

                                                #$vnet.Subnets[0].ServiceEndpoints  # Display the first endpoint.
                                                #Write-Host "Vnet Subnet Service Endpoints :" $vnet.Subnets[0].ServiceEndpoints 

                                                # END: Create a Virtual Service endpoint on the subnet
                                            }

                                            Write-Host "Service EndPoints string value in module:" $strExistingServiceEndpoints
                                        }
                                        # This is the scenario of rollback / cleanup of 'Microsoft.Storage' service endpoint configuration (if added earlier via this workflow/script)
                                        elseif (1 -eq $serviceEndPointsRuleCleanup) {
                                            
                                            # START: Rollback the Service endpoints on the VM subnet
                                            Write-Host "Rollback 'Microsoft.Storage' Service Endpoint from the VM subnet."

                                            # Code to remove the blank items from the array object. 
                                            # Somehow when passing array from PS module to Calling PS script it adds few blank values in the array (for storing backup service endpoints)
                                            #$exitingServiceEndpointsOptimized = $exitingServiceEndpoints | Where-Object { [string]::IsNullOrWhiteSpace($_.Service)}
                                            $exitingServiceEndpointsOptimized = $exitingServiceEndpoints.Where({ $_ -ne "" })

                                            # At-times when passing array from PS module to Calling PS script it adds few duplicate values in the array. However, then tested more it was not having these duplicate values, so below line is commented.
                                            #$exitingServiceEndpointsOptimized = $exitingServiceEndpointsOptimized | Get-Unique

                                            $existingServiceEndPointsArray = @()
                                            foreach ($existingSvcEndpoint in $exitingServiceEndpointsOptimized) {
                                                if(![string]::IsNullOrWhiteSpace($existingSvcEndpoint.Service)) {
                                                    Write-Host "Pre-existing Service Endpoint Name for Rollback in module :" $existingSvcEndpoint.Service
                                                    $existingServiceEndPointsArray += $existingSvcEndpoint.Service
                                                }
                                            }

                                            # Code to supress the warning message 
                                            Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

                                            $vnetSubParams = @{
                                                Name            = $subnet_name
                                                AddressPrefix   = $subnetConfig.AddressPrefix
                                                VirtualNetwork  = $vnet
                                                ServiceEndpoint = $existingServiceEndPointsArray
                                            }
                                            $vnet = Set-AzVirtualNetworkSubnetConfig @vnetSubParams

                                            Write-Host "Persist the updates made to the virtual network > subnet."

                                            # Persist the updates made to the virtual network > subnet.
                                            $vnet = Set-AzVirtualNetwork -VirtualNetwork $vnet

                                            #$vnet.Subnets[0].ServiceEndpoints  # Display the first endpoint.
                                            #Write-Host "Vnet Subnet Service Endpoints :" $vnet.Subnets[0].ServiceEndpoints 

                                            # END: Rollback the Service endpoints on the VM subnet
                                            
                                        }

                                        # Code to configure temp storage account within the VM's VNet & Subnet
                                        Add-AzStorageAccountNetworkRule -ResourceGroupName $tempStorageAccountRGName -Name $tempStorageAccount -VirtualNetworkResourceId $subnet.Id
                                        Write-Host "Configured VM $vmName Subnet $subnet_name to Storage Account $tempStorageAccount Virtual Networks"
                                        
                                        # Code to updated the default virtual network configuration for Storage Account
                                        Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $tempStorageAccountRGName -Name $tempStorageAccount -DefaultAction Deny
                                        Write-Host "Updated default virtual network configuration for Storage Account $tempStorageAccount to selected Virtual Networks and IP addresses"
                                        
                                    }
                                    else {
                                        Write-Host "Error in getting subnet configuration of the vm"
                                    }
                                }
                                else {
                                    Write-Host "Error in instantiating vnet of the vm"
                                }
                            }
                            else {
                                Write-Host "Error in getting the subnet name of the vm"
                            }
                        }
                        else {
                            Write-Host "Error in instantiating subnet of the vm"
                        }
                    }
                    else {
                        Write-Host "Error in vm nic object"
                    }
                }
                else {
                    Write-Host "Error in vm nic name"
                }

            }
            else {
                Write-Host "Error in creating VM Object from vm name"
            }
        }

        # Return the pre-existing service endpoints of the vm vnet / subnet. 
        # This will be needed to roll-back service endpoints after hardening script execution by calling this module again.
        return $SvcEndPoints
        #return $strExistingServiceEndpoints
    }
    catch {
        Write-Error 'Module Error in creating service endpoints' $_.Exception.Message
    }
}
