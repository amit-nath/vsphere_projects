############## Helper Methods ##############
Function Add-SerialPort {
  Param (
      [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
      $VM,
	  [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
      $IP
  )
  Write-Host ">>> VM Name - $VM, vSPC IP - $IP`n"
  $dev = New-Object VMware.Vim.VirtualDeviceConfigSpec
  $dev.operation = "add"
  $dev.device = New-Object VMware.Vim.VirtualSerialPort
  $dev.device.key = -1
  $dev.device.backing = New-Object VMware.Vim.VirtualSerialPortURIBackingInfo
  $dev.device.backing.direction = "server"
  $dev.device.backing.serviceURI = "vSPC.py"
  $dev.device.backing.ProxyURI = "telnet://" + $IP +":13370"
  $dev.device.connectable = New-Object VMware.Vim.VirtualDeviceConnectInfo
  $dev.device.connectable.connected = $true
  $dev.device.connectable.StartConnected = $true
  $dev.device.yieldOnPoll = $true

  $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
  $spec.DeviceChange += $dev

  $vm_obj = Get-VM -Name $VM
  $vm_obj.ExtensionData.ReconfigVM($spec)
}

Function Get-SerialPort {
    Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        $VM
    )
    Process {
        Foreach ($VMachine in $VM) {
            Foreach ($Device in $VMachine.ExtensionData.Config.Hardware.Device) {
                If ($Device.gettype().Name -eq "VirtualSerialPort"){
                    $Details = New-Object PsObject
                    $Details | Add-Member Noteproperty VM -Value $VMachine
                    $Details | Add-Member Noteproperty Name -Value $Device.DeviceInfo.Label
                    If ($Device.Backing.FileName) { $Details | Add-Member Noteproperty Filename -Value $Device.Backing.FileName }
                    If ($Device.Backing.Datastore) { $Details | Add-Member Noteproperty Datastore -Value $Device.Backing.Datastore }
                    If ($Device.Backing.DeviceName) { $Details | Add-Member Noteproperty DeviceName -Value $Device.Backing.DeviceName }
                    $Details | Add-Member Noteproperty Connected -Value $Device.Connectable.Connected
                    $Details | Add-Member Noteproperty StartConnected -Value $Device.Connectable.StartConnected
                    $Details
                }
            }
        }
    }
}

Function Remove-SerialPort {
	Param (
        [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
        $VM
    )
	$NotWantedHardware = "Serial"
	$ConfigureVM = $true
	$VMs = Get-VM $VM

	foreach ($vmx in $VMs){
	  $vUnwantedHw = @()
	  $vmxv = $vmx | Get-View
	  $vmxv.Config.Hardware.Device | where {$_.DeviceInfo.Label -match $NotWantedHardware} | %{
		$myObj = "" | select Hardware, Key, RemoveDev, Dev
		$myObj.Hardware = $_.DeviceInfo.Label
		$myObj.Key = $_.Key
		$myObj.Dev = $_
		if ($vmx.powerstate -notmatch "PoweredOn" -or $_.DeviceInfo.Label -match "USB"){$MyObj.RemoveDev = $true}
		else {$MyObj.RemoveDev = $false}
		$vUnwantedHw += $myObj | Sort Hardware
	  }
	  Write-Host ">>> INFO: Here is $($VMX)'s unwanted hardware"
	  # $vUnwantedHw | Select Hardware, @{N="Can be Removed";E="RemoveDev"} | ft -AutoSize #Output for display
	  $vUnwantedHw | Select Hardware, @{N="Can be Removed";E="RemoveDev"}
	  if($ConfigureVM){# Unwanted Hardware is configured for removal
		$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
		foreach($dev in $vUnwantedHw){
		  if($dev.RemoveDev -eq $true){
			$vmConfigSpec.DeviceChange += New-Object VMware.Vim.VirtualDeviceConfigSpec
			$vmConfigSpec.DeviceChange[-1].device = $dev.Dev
			$vmConfigSpec.DeviceChange[-1].operation = "remove"
			Write-Host "Removed $($dev.Hardware)"
		  }
		}
		$vmxv.ReconfigVM_Task($vmConfigSpec)
	  }# Unwanted Hardware is configured for removal
	}
}
