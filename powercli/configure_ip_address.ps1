. "lib\init.ps1"
. "lib\finalize.ps1"

Initialize


foreach ($vm in $new_vms)
{
    Write-Host "======================================================"
    Write-Host ">>> $vm IP configuration started ..."
    $ip_address = (nslookup -q=A $vm $pfsense_router | Select-String Address | Select -Last 1).ToString().Split(' ')[-1]
    Write-Host ">>> $vm IP Address: $ip_address"
    $ip_octets = $ip_address.Split('.')
    $ip_gateway = $ip_octets[0] + '.' + $ip_octets[1] + '.' + $ip_octets[2] + '.' + '1'
    Write-Host ">>> $vm IP Gateway: $ip_gateway"
    if ($os_type -like "*window*")
    {
        $interface = (Invoke-VMScript -VM $vm -ScriptType PowerShell -ScriptText "(gwmi Win32_NetworkAdapter -filter 'netconnectionid is not null').netconnectionid" -GuestUser template -GuestPassword Password1).ScriptOutput.Trim()
        Write-Host ">>> $vm Network Interface: $interface"

        $set_ip_cmd = "c:\windows\system32\netsh.exe interface ip set address ""$interface"" static $ip_address $mgmt_netmask $ip_gateway"
        $set_dns_cmd = "c:\windows\system32\netsh.exe interface ip set dnsservers ""$interface"" static $dns_server"

        # *** -GuestUser & -GuestPassword this values need to replaced or get from ENV and set in init.ps1 library ***
        Invoke-VMScript -VM $vm -ScriptType bat -ScriptText $set_ip_cmd -GuestUser <guesuser> -GuestPassword <guespassword>
        Invoke-VMScript -VM $vm -ScriptType bat -ScriptText $set_dns_cmd -GuestUser <guesuser> -GuestPassword <guespassword>
    }
    elseif ($os_type -like "*centos*")
    {
        $guestOsUser = "root"
        $guestOsPassword = "guestuserpassword"    # update the guest os root password
        $interface = (Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText 'ls /etc/sysconfig/network-scripts/ | grep ifcfg | grep -v lo | head -1' -GuestUser $guestOsUser -GuestPassword $guestOsPassword).ScriptOutput.Trim()
        $intf_file = '/etc/sysconfig/network-scripts/' + $interface
        Write-Host ">>> $vm Network Interface File: $intf_file"
        Write-Host ">>> $vm Set BOOTPROTO: static"
        Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "sed -i -r -e 's/BOOTPROTO=.*/BOOTPROTO\=static/g' $intf_file" -GuestUser $guestOsUser -GuestPassword $guestOsPassword
        Write-Host ">>> $vm Set ONBOOT: yes"
        Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "sed -i -r -e 's/ONBOOT=.*/ONBOOT\=yes/g' $intf_file" -GuestUser $guestOsUser -GuestPassword $guestOsPassword

        $has_ipaddr = (Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "grep IPADDR $intf_file" -GuestUser $guestOsUser -GuestPassword ironport).ScriptOutput.Trim()
        if ($has_ipaddr)
        {
            Write-Host ">>> $vm already has IP ADDRESS configured"
            Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "sed -i -r -e 's/IPADDR=.*/IPADDR\=$ip_address/g' $intf_file" -GuestUser $guestOsUser -GuestPassword $guestOsPassword
            Write-Host ">>> $vm IP ADDRESS updated"
        }
        else
        {
            Write-Host ">>> $vm does not have IP ADDRESS configured"
            Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "echo IPADDR=$ip_address >> $intf_file" -GuestUser $guestOsUser -GuestPassword $guestOsPassword
            Write-Host ">>> $vm IP ADDRESS added"
        }

        $has_netmask = (Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "grep NETMASK $intf_file" -GuestUser $guestOsUser -GuestPassword $guestOsPassword).ScriptOutput.Trim()
        if ($has_netmask)
        {
            Write-Host ">>> $vm already has NETMASK configured"
            Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "sed -i -r -e 's/NETMASK=.*/NETMASK\=$mgmt_netmask/g' $intf_file" -GuestUser $guestOsUser -GuestPassword $guestOsPassword
            Write-Host ">>> $vm NETMASK updated"
        }
        else
        {
            Write-Host ">>> $vm does not have NETMASK configured"
            Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "echo NETMASK=$mgmt_netmask >> $intf_file" -GuestUser $guestOsUser -GuestPassword $guestOsPassword
            Write-Host ">>> $vm NETMASK added"
        }

        $has_gateway = (Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "grep GATEWAY $intf_file" -GuestUser $guestOsUser -GuestPassword $guestOsPassword).ScriptOutput.Trim()
        if ($has_gateway)
        {
            Write-Host ">>> $vm already has GATEWAY configured"
            Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "sed -i -r -e 's/GATEWAY=.*/GATEWAY\=$ip_gateway/g' $intf_file" -GuestUser $guestOsUser -GuestPassword $guestOsPassword
            Write-Host ">>> $vm GATEWAY updated"
        }
        else
        {
            Write-Host ">>> $vm does not have GATEWAY configured"
            Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "echo GATEWAY=$ip_gateway >> $intf_file" -GuestUser $guestOsUser -GuestPassword $guestOsPassword
            Write-Host ">>> $vm GATEWAY added"
        }

        Invoke-VMScript -VM $vm -ScriptType Bash -ScriptText "echo $vm > /etc/hostname" -GuestUser $guestOsUser -GuestPassword $guestOsPassword
        Write-Host ">>> $vm HOSTNAME updated"

        Write-Host ">>> $vm Reboot initiated"
        Restart-VMGuest -VM $vm -Confirm:$false
        Start-Sleep  10
        Write-Host ">>> $vm Waiting for VMWare Tools to respond"
        Wait-Tools -VM $vm -TimeoutSeconds 300
    }
    Write-Host ">>> $vm IP configuration completed"
    Write-Host "======================================================\n\n"
}

Finalize