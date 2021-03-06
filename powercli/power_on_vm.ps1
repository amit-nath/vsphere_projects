. "lib\init.ps1"
. "lib\finalize.ps1"

Initialize

foreach ($vm in $new_vms)
{
    Write-Host ""
    $vmo = Get-VM $vm
    if ($?)
    {
        if ($vmo.PowerState -eq 'PoweredOn')
        {
            Write-Host ">>> INFO: $vm is already Powered on"  -foregroundcolor "yellow"
        }
        else
        {
            Write-Host ">>> INFO: Powering on $vm ... " -foregroundcolor "darkcyan"
            $task = Start-VM $vm -Confirm:$false
            Write-Host ">>> INFO: Power on task completed." -foregroundcolor "green"
            if ($os_type -like "*freebsd*")
            {
                # 15 minutes Wait for FreeBSD clients to boot
                Write-Host ">>> INFO: Waiting 15 minutes for FreeBSD to boot"
                Start-Sleep  900
            }
            elseif ($os_type -like "*windows*" -or $os_type -like "*centos*")
            {
                Write-Host ">>> INFO: Waiting for VMWare Tools to respond"
                Wait-Tools -VM $vm -TimeoutSeconds 900
            }
            else
            {
                # Sleep for 5 minutes to Guest OS to boot
                Write-Host ">>> INFO: Waiting 15 minutes for $vm to boot"
                Start-Sleep  300
            }
        }
    }
    else
    {
        Write-Host ">>> ERROR: VM $vm does not exists"
    }
}

Finalize