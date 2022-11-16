<#
    .SYNOPSIS
        Code to add or remove Network Security Rules
    .DESCRIPTION
        Code to add or remove Network Security Rules in a Network Security Group
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 30 June 2022
        Modified By: Anil Kumar
        Modified Date: 30 June 2022
#>

function ManageNetworkSecurityRules {
    param (
        $networkSecurityRuleType, # Options are 0 or 1. When 1 network security rule is added. When 0 network security rule is removed.
        $nsgInternetRuleName,
        $nsgAzureCloudRuleName,
        $vmName,    
        $vmResourceGroupName
    )

    $stepNumberHardening = $null
    if(1 -eq $networkSecurityRuleType) {
        $stepNumberHardening = 4
    }
    elseif(0 -eq $networkSecurityRuleType) {
        $stepNumberHardening = 7
    }
    Write-Host "******************************************************************************************************************************"
    Write-Host "STEP $stepNumberHardening : Manage Network Security Rules ps module received a request"
    Write-Host "******************************************************************************************************************************"

    Write-Host "Network Security Rule Type received from Pipeline :" $networkSecurityRuleType
    Write-Host "Network Security Rule Name for Internet blocking received from Pipeline :" $nsgInternetRuleName
    Write-Host "Network Security Rule Name for allowing Azure Cloud received from Pipeline :" $nsgAzureCloudRuleName
    Write-Host "VM Name from Pipeline :" $vmName
    Write-Host "VM Resource Group received from Pipeline  :" $vmResourceGroupName

    $networkSecurityRuleStatus = $false

    try {
        $nsgObj = (Get-AzNetworkInterface -ResourceId (Get-AzVM -ResourceGroupName $vmResourceGroupName -ResourceName $vmName).NetworkProfile.NetworkInterfaces.Id).NetworkSecurityGroup
        if(!($null -eq $nsgObj)) {
            $nsgID = $nsgObj.Id.ToString()
            #Write-Host 'NSG ID :' $nsgID
            $lastIndex = $nsgID.LastIndexOf('/')
            #Write-Host 'NSG ID LAST INDEX OF SLASH :'$lastIndex
            $nsgName = $nsgID.Substring($lastIndex+1)
            #Write-Host 'NSG NAME :'$nsgName

            $nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $vmResourceGroupName
            if(!($null -eq $nsg)) {
                #Write-Host 'Instantiated NSG'
                # When $ruleType = 1, network security rule is added.
                if(1 -eq $networkSecurityRuleType) {
                    Write-Host 'Adding Network Security Rules of Deny Internet and Allow Azure Cloud'

                    $networkSecurityRuleDesc = 'Deny Outbound Internet Access'
                    $networkSecurityRuleAzureDesc = 'Allow Outbound access to Azure Cloud for downloading hardening files from Storage Blob'
                    
                    # Add NSG rule to allow Azure portal for downloading hardening files from Storage Blob
                    Add-AzNetworkSecurityRuleConfig -Name $nsgAzureCloudRuleName -NetworkSecurityGroup $nsg -Description $networkSecurityRuleAzureDesc -Access Allow -Protocol Tcp -Direction Outbound -Priority 101 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix AzureCloud -DestinationPortRange 443 | Set-AzNetworkSecurityGroup
                    
                    # Add NSG rule to Block Public internet 
                    Add-AzNetworkSecurityRuleConfig -Name $nsgInternetRuleName -NetworkSecurityGroup $nsg -Description $networkSecurityRuleDesc -Access Deny -Protocol * -Direction Outbound -Priority 102 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix Internet -DestinationPortRange * | Set-AzNetworkSecurityGroup

                    $networkSecurityRuleStatus = $true
                }
                # When $ruleType = 0, network security rule is added.
                elseif (0 -eq $networkSecurityRuleType) {
                    Write-Host 'Removing Network Security Rules of Deny Internet and Allow Azure Cloud'
                    
                    # Remove NSG rule to Block Public internet 
                    Remove-AzNetworkSecurityRuleConfig -Name $nsgInternetRuleName -NetworkSecurityGroup $nsg | Set-AzNetworkSecurityGroup

                    # Remove NSG rule to allow Azure portal for downloading hardening files from Storage Blob
                    Remove-AzNetworkSecurityRuleConfig -Name $nsgAzureCloudRuleName -NetworkSecurityGroup $nsg | Set-AzNetworkSecurityGroup
                    $networkSecurityRuleStatus = $true
                }
            }
            else {
                Write-Error 'Error in instantiating NSG' $_.Exception.Message
            }
        }
        else {
            Write-Error 'Error in instantiating NSG property' $_.Exception.Message
        }
    }
    catch {
        Write-Error 'Error in managing network security rule' $_.Exception.Message
    }
    return $networkSecurityRuleStatus
}