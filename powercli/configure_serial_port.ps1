. "lib\init.ps1"
. "lib\finalize.ps1"
. "lib\serial_port.ps1"

Initialize

$pcloud_wan_ip = $([System.Net.Dns]::GetHostAddresses($pfsense_router)).IPAddressToString

foreach ($vm in $new_vms)
{
    Write-Host ""
    $vmo = Get-VM $vm
    if ($?)
    {
        $has_serial_port = $vmo | Get-SerialPort
        if (!$has_serial_port)
        {
            if ($vmo.PowerState -eq 'PoweredOff')
            {
                Write-Host ">>> INFO: $vm is already Powered off"  -foregroundcolor "yellow"
            }
            else
            {
                Write-Host ">>> INFO: Powering off $vm ... " -foregroundcolor "darkcyan"
                $task = Stop-VM $vm -Confirm:$false
                Write-Host ">>> INFO: Power off task completed. " -foregroundcolor "green"
            }
            Write-Host ">>> INFO: Adding Serial Port for vSPC.py in $vm ... " -foregroundcolor "darkcyan"
            Add-SerialPort $vm $pcloud_wan_ip
            Write-Host ">>> INFO: Add Serial Port task completed. " -foregroundcolor "green"
        }
        else
        {
            Write-Host ">>> INFO: $vm aleady has Seril Port configured." -foregroundcolor "yellow"
            Write-Host ">>> INFO: Removing existing Serial Port ..."
            if ($vmo.PowerState -eq 'PoweredOff')
            {
                Write-Host ">>> INFO: $vm is already Powered off"  -foregroundcolor "yellow"
            }
            else
            {
                Write-Host ">>> INFO: Powering off $vm ... " -foregroundcolor "darkcyan"
                $task = Stop-VM $vm -Confirm:$false
                Write-Host ">>> INFO: Power off task completed. " -foregroundcolor "green"
            }
            Remove-SerialPort $vm
            Write-Host ">>> INFO: Adding Serial Port for vSPC.py in $vm ... " -foregroundcolor "darkcyan"
            Add-SerialPort $vm $pcloud_wan_ip
            Write-Host ">>> INFO: Add Serial Port task completed. " -foregroundcolor "green"
        }
    }
    else
    {
        Write-Host ">>> ERROR: VM $vm does not exists"
    }
}

Finalize
