﻿
<#PSScriptInfo

.VERSION 0.1.0

.GUID edd05043-2acc-48fa-b5b3-dab574621ba1

.AUTHOR Michael Greene

.COMPANYNAME Microsoft Corporation

.COPYRIGHT 

.TAGS DSCConfiguration

.LICENSEURI https://github.com/Microsoft/DomainControllerConfig/blob/master/LICENSE

.PROJECTURI https://github.com/Microsoft/DomainControllerConfig

.ICONURI 

.REQUIREDMODULES xActiveDirectory,xStorage 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
https://github.com/Microsoft/DomainControllerConfig/blob/master/README.md#versions

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

<#

.DESCRIPTION 
 Demonstrates a minimally viable domain controller configuration script
 compatible with Azure Automation Desired State Configuration service.
 
 Required variables in Automation service:
  - domainName - string that will be used as the Active Directory domain
  - domainCredential - credential to use for AD domain admin
  - safeModeCredential - credential to use for Safe Mode recovery

Require configuration for the virtual machine
  - Must have an OS disk and a data disk for the AD database to be configured on

Required modules in Automation service:
  - xActiveDirectory
  - xStorage

#>

configuration DomainControllerConfig
{

    Import-DscResource -ModuleName 'xActiveDirectory', 'xStorage'

    $domainCredential = Get-AutomationPSCredential 'Credential'
    $safeModeCredential = Get-AutomationPSCredential 'Credential'
    
    Node $AllNodes.NodeName
    {
        WindowsFeature ADDSInstall {
            Ensure = 'Present'
            Name   = 'AD-Domain-Services'
        }
        xWaitforDisk Disk2
        {
            DiskId           = 2
            RetryIntervalSec = 10
            RetryCount       = 30
        }
        xDisk DiskF
        {
            DiskId      = 2
            DriveLetter = 'F'
        }
        xADDomain Domain
        {
            DomainName                    = $Node.domainName
            DomainAdministratorCredential = $domainCredential
            SafemodeAdministratorPassword = $safeModeCredential
            DatabasePath                  = $Node.DatabasePath
            LogPath                       = $Node.LogPath
            SysvolPath                    = $Node.SysvolPath
            DependsOn                     = '[WindowsFeature]ADDSInstall'
        }
    }
}
