. "lib\init.ps1"
. "lib\finalize.ps1"

Initialize

foreach ($vm in $new_vms)
{
    Write-Host ""
    $vmo = Get-VM $vm
    if ($?)
    {
        Write-Host ">>> INFO: Restarting $vm ... " -foregroundcolor "darkcyan"
        $task = Restart-VM -VM $vm -Confirm:$false
        Write-Host ">>> INFO: VM Restart task completed." -foregroundcolor "green"
    }
    else
    {
        Write-Host ">>> ERROR: VM $vm does not exists"
    }
}

Finalize