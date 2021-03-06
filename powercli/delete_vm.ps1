. "lib\init.ps1"
. "lib\finalize.ps1"

Initialize

foreach ($vm in $new_vms)
{
    Write-Host ""
    $vmo = Get-VM $vm
    if ($?)
    {
        if ($vmo.PowerState -ne 'PoweredOff')
        {
            Write-Host ">>> INFO: Powering off $vm ... " -foregroundcolor "darkcyan"
            Stop-VM $vm Confirm:$false
            Write-Host ">>> INFO: Power Off VM task completed." -foregroundcolor "green"
        }
        else
        {
            Write-Host ">>> INFO: $vm is already powered off ... " -foregroundcolor "darkcyan"
        }
        Write-Host ">>> INFO: Deleting $vm from Disk... " -foregroundcolor "darkcyan"
        $task = Remove-VM $vm -DeleteFromDisk -Confirm:$false
        Write-Host ">>> INFO: Delete VM task completed." -foregroundcolor "green"
    }
    else
    {
        Write-Host ">>> WARNING: VM $vm does not exists" -foregroundcolor "yellow"
    }
}

Finalize