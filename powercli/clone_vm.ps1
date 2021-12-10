. "lib\init.ps1"
. "lib\finalize.ps1"
#. "lib\misc.ps1"

Initialize

$dest_folder = Get-Folder -type VM -name "$pcloud"
Write-Host ">>> Destination folder: $dest_folder`n"
$resourcepool = Get-ResourcePool -Name $resource_pool
Write-Host ">>> ResourcePool: $resourcepool`n"

foreach ($vm in $new_vms)
{
    Write-Host ""
    $vmo = Get-VM $vm
    if (!$?)
    {
        Write-Host ">>> INFO: Cloning $vm from $clone_from ... " -foregroundcolor "darkcyan"
#        $datastore = GetDataStore
#        Write-Host ">>> INFO: DataStore to use for Clone-VM - $datastore" -foregroundcolor "darkcyan"
        $task = New-VM -Name $vm -Template $template -Location $dest_folder -ResourcePool $resourcepool -Confirm:$false
        Write-Host ">>> INFO: Cloning task completed." -foregroundcolor "green"
    }
    else
    {
        Write-Host ">>> INFO: VM $vm already exists"
    }
}

Finalize