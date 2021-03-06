. "lib\init.ps1"
. "lib\finalize.ps1"

Initialize

foreach ($vm in $new_vms)
{
    Write-Host ""
    $vmo = Get-VM $vm
    if ($?)
    {
        Write-Host "`n>>> INFO: Setting network adapter for $vm`n"
        $nics = $vmo | Get-NetworkAdapter
        foreach ($nic in $nics)
        {
            if ($nic.Name -eq "Network Adapter 1")
            {
                if ($nic.NetworkName -ne $mgmt_vlan)
                {
                    Write-Host ">>> INFO: Set network adapter of " $vm.Name " to $mgmt_vlan"
                    $task = $nic | Set-NetworkAdapter -NetworkName $mgmt_vlan -Confirm:$false
                }
                else
                {
                    Write-Host ">>> INFO: Network adapter of " $vm.Name " is already set to $mgmt_vlan"
                }
            }
            else
            {
                if ($nic.Name -eq "Network Adapter 2")
                {
                    if ($nic.NetworkName -ne $data1_vlan)
                    {
                        Write-Host ">>> INFO: Set network adapter of " $vm.Name " to $data1_vlan"
                        $task = $nic | Set-NetworkAdapter -NetworkName $data1_vlan -Confirm:$false
                    }
                    else
                    {
                        Write-Host ">>> INFO: Network adapter of " $vm.Name " is already set to $data1_vlan"
                    }
                }
                else
                {
                    if ($nic.NetworkName -ne $data2_vlan)
                    {
                        Write-Host ">>> INFO: Set network adapter of " $vm.Name " to $data2_vlan"
                        $task = $nic | Set-NetworkAdapter -NetworkName $data2_vlan -Confirm:$false
                    }
                    else
                    {
                        Write-Host ">>> INFO: Network adapter of " $vm.Name " is already set to $data2_vlan"
                    }
                }
            }
        }
    }
    else
    {
        Write-Host ">>> ERROR: VM $vm does not exists"
    }
}

Finalize