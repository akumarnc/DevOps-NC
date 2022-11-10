<#
    .SYNOPSIS
        Code to set maximum size for windows event logs.
    .DESCRIPTION
        Code to set maximum size for windows event logs (application, system, security and powershell).
    .NOTES
        Version: 0.1
        Created By: Anil Kumar
        Creation Date: 10 June 2022
        Modified By: Anil Kumar
        Modified Date: 20 June 2022
#>

Write-Host "Windows log size settings script processed a request"

# Read the JSON file for Windows Logging configurations
$windowsLoggingConfigFile = Get-Content -Raw -Path .\LoggingConfig.json
$psObjWindowsLoggingConfigFile = ConvertFrom-Json $windowsLoggingConfigFile

$psObjWindowsLoggingConfigFile | Select-Object -Property EventsMaxLogSize

# Initialize the variable for maximum windows logs size
$max_Log_Size_Application = $psObjWindowsLoggingConfigFile.EventsMaxLogSize.Application
$max_Log_Size_System = $psObjWindowsLoggingConfigFile.EventsMaxLogSize.System
$max_Log_Size_Security = $psObjWindowsLoggingConfigFile.EventsMaxLogSize.Security
$max_Log_Size_PS = $psObjWindowsLoggingConfigFile.EventsMaxLogSize.PowerShell

Write-Host "Max Application Log Size" $max_Log_Size_Application
Write-Host "Max System Log Size" $max_Log_Size_System
Write-Host "Max Security Log Size" $max_Log_Size_Security
Write-Host "Max PowerShell Log Size" $max_Log_Size_PS

try {

Configuration CIS_WindowsServer2019_EventLog_Config {
    param (
        [string[]]$computerName = 'localhost',
        [string]$maxLogSizeApplication = $max_Log_Size_Application,
        [string]$maxLogSizeSystem = $max_Log_Size_System,
        [string]$maxLogSizeSecurity = $max_Log_Size_Security,
        [string]$maxLogSizePS = $max_Log_Size_PS
    )

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'

    Node $computerName {

        Registry 'maxlogsize-application' {
            Ensure    = 'Present'
            Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Application'
            ValueName = 'maxsize'
            ValueType = 'DWORD'
            ValueData =  $maxLogSizeApplication
        }

        Registry 'maxlogsize-system' {
            Ensure    = 'Present'
            Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\System'
            ValueName = 'maxsize'
            ValueType = 'DWORD'
            ValueData = $maxLogSizeSystem
        }

        Registry 'maxlogsize-security' {
            Ensure    = 'Present'
            Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Security'
            ValueName = 'maxsize'
            ValueType = 'DWORD'
            ValueData = $maxLogSizeSecurity
        }

        Registry 'maxlogsize-ps' {
            Ensure    = 'Present'
            Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EventLog\Windows PowerShell'
            ValueName = 'maxsize'
            ValueType = 'DWORD'
            ValueData = $maxLogSizePS
        }
    }
}

CIS_WindowsServer2019_EventLog_Config

### Apply Policies in mof file

# Apply Hardening Dsc configuration
Start-DscConfiguration -Path .\CIS_WindowsServer2019_EventLog_Config -Force -Verbose -Wait 

# Remove mof file
Remove-Item .\CIS_WindowsServer2019_EventLog_Config -Force -recurse

}
catch {
    Write-Error 'Error in configuring windows log size settings' $_.Exception.Message
}
