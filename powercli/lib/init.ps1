function Initialize() {
    Add-PSSnapin VMware.VimAutomation.Core
    Add-PSSnapin VMware.VimAutomation.Vds
    if(get-item HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\VMware.VimAutomation.Core){
        . ((get-item HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellSnapIns\VMware.VimAutomation.Core).GetValue("ApplicationBase")+"\Scripts\Initialize-PowerCLIEnvironment.ps1")
    }
    else
    {
        write-warning "PowerCLI Path not found in registry, please set path to Initialize-PowerCLIEnvironment.ps1 manually. Is PowerCli aleady installed?"
        . "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLIScripts\Initialize-PowerCLIEnvironment.ps1"
    }

    $ErrorActionPreference = "Stop"

    Set-Variable -Name "vcenter_hostname" -Scope "global" -Value $Env:VCENTER_HOSTNAME
    Set-Variable -Name "vcenter_username" -Scope "global" -Value $Env:VCENTER_USERNAME
    Set-Variable -Name "vcenter_password" -Scope "global" -Value $Env:VCENTER_PASSWORD
    Set-Variable -Name "pcloud" -Scope "global" -Value $Env:PCLOUD
    Set-Variable -Name "pfsense_router" -Scope "global" -Value $Env:PCLOUD_PFSENSE_ROUTER
    Set-Variable -Name "resource_pool" -Scope "global" -Value $Env:RESOURCE_POOL
    Set-Variable -Name "template" -Scope "global" -Value $Env:TEMPLATE
    Set-Variable -Name "new_vms" -Scope "global" -Value $Env:NEW_VMS.split(",")
    Set-Variable -Name "vm_type" -Scope "global" -Value $Env:VM_TYPE
    Set-Variable -Name "os_type" -Scope "global" -Value $Env:OPERATING_SYSTEM

    Set-Variable -Name "mgmt_vlan" -Scope "global" -Value $Env:MGMT_VLAN
    Set-Variable -Name "data1_vlan" -Scope "global" -Value $Env:DATA1_VLAN
    Set-Variable -Name "data2_vlan" -Scope "global" -Value $Env:DATA2_VLAN

    Set-Variable -Name "mgmt_netmask" -Scope "global" -Value $Env:MGMT_NETMASK
    Set-Variable -Name "data1_netmask" -Scope "global" -Value $Env:DATA1_NETMASK
    Set-Variable -Name "data2_netmask" -Scope "global" -Value $Env:DATA2_NETMASK

    Set-Variable -Name "dns_server" -Scope "global" -Value $Env:DNS_SERVER

    Write-Host "`n`n###################### USER PASSED PARAMS #########################"
    Write-Host "# Vcenter Hostname:	$vcenter_hostname"
    Write-Host "# Vcenter Username:	$vcenter_username"
    Write-Host "# Vcenter Password:	$vcenter_password"
    Write-Host "# PCloud:        	$pcloud"
    Write-Host "# Pfsense Router:   $pfsense_router"
    Write-Host "# Resource Pool: 	$resource_pool"
    Write-Host "# Template:      	$template"
    Write-Host "# Mgmt Vlan:     	$mgmt_vlan"
    Write-Host "# Data1 Vlan:    	$data1_vlan"
    write-Host "# Data2 Vlan:    	$data2_vlan"
    Write-Host "# Mgmt Netmask:    	$mgmt_netmask"
    Write-Host "# Data1 Netmask:   	$data1_netmask"
    write-Host "# Data2 Netmask:   	$data2_netmask"
    Write-Host "# New Vms:       	$new_vms"
    Write-Host "# VM Type:       	$vm_type"
    Write-Host "# OS Type:       	$os_type"
    Write-Host "###################################################################`n`n"

    Write-Host "#~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Initialize ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#"
    Write-Host "# Connect to VCENTER $vcenter"
    Write-Host "#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Connect-VIServer $vcenter_hostname -User $vcenter_username -Password $vcenter_password -WarningAction SilentlyContinue
    Write-Host ">>> Successfully connected to vcenter`n"
}
