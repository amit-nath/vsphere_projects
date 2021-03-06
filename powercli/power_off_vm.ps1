. "lib\init.ps1"
. "lib\finalize.ps1"

Initialize

foreach ($vm in $new_vms)
{
    Write-Host ""
    $vmo = Get-VM $vm
    if ($?)
    {
        if ($vmo.PowerState -eq 'PoweredOff')
        {
            Write-Host ">>> INFO: $vm is already Powered off"  -foregroundcolor "yellow"
        }
        else
        {
            Write-Host ">>> INFO: Powering off $vm ... " -foregroundcolor "darkcyan"
            $task = Stop-VM $vm -Confirm:$false
            Write-Host ">>> INFO: Power off task completed." -foregroundcolor "green"
        }
    }
    else
    {
        Write-Host ">>> ERROR: VM $vm does not exists"
    }
}

Finalize