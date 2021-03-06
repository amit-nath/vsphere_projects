. "lib\init.ps1"
. "lib\finalize.ps1"

Initialize

foreach ($vm in $new_vms)
{
    Write-Host ""
    $vmo = Get-VM $vm
    if ($?)
    {
        Write-Host ">>> INFO: Powring off VM $vm" -foregroundcolor "yellow"
        $task = Stop-VM $vm -Confirm:$false
        if ($?)
        {
            Write-Host ">>> INFO: Successfully powered off $vm" -foregroundcolor "green"
        }
        else
        {
            Write-Host ">>> INFO: VM $vm is already powered off" -foregroundcolor "yellow"
        }

        Write-Host ">>> INFO: Setting boot order to network" -foregroundcolor "yellow"
        $vmView = $vmo | Get-View
        $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
        $spec.extraConfig = New-Object VMware.Vim.OptionValue
        $spec.extraConfig[0].key = "bios.bootDeviceClasses"
        $spec.extraConfig[0].value = "allow:net"
        $task = $vmView.ReconfigVM_Task($spec)

        Write-Host ">>> INFO: Powring on VM" -foregroundcolor "yellow"
        $task = Start-VM $vm -Confirm:$false

        Write-Host ">>> INFO: Setting boot order to HDD" -foregroundcolor "yellow"
        $spec.extraConfig[0].value = "allow:hd,net,cd,fd"
        $task = $vmView.ReconfigVM_Task($spec)
        Write-Host "`n>>> INFO: PXE boot config for VM $vm completed`n"
        Write-Host "`n>>> INFO: Netinstall started on $vm. $vm should come up within 10-15 mins`n"
    }
    else
    {
        Write-Host ">>> ERROR: VM $vm does not exists"
    }
}

Finalize