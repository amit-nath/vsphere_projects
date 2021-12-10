function GetDataStore()
{
    $VmHost = Get-Cluster $pcloud | Get-VMHost | Where { $_.PowerState -eq 'PoweredOn' -and $_.ConnectionState -eq 'Connected' } | Get-Random
    if (!$?)
    {
        $VmHost = Get-Cluster 'pcloud-cluster' | Get-VMHost | Where { $_.PowerState -eq 'PoweredOn' -and $_.ConnectionState -eq 'Connected' } | Get-Random
    }
    $AllDataStores = $VmHost | Get-Datastore | Sort FreeSpaceGB -Descending
    $DataStores = New-Object System.Collections.ArrayList
    for ($i = 0; $i -lt $AllDataStores.Length; $i++) {
        if ($AllDataStores[$i].Name.ToLower() -ne 'netboot' -and $AllDataStores[$i].Name.ToLower() -ne 'scratch')
        {
            $DataStores.Add($AllDataStores[$i]) > $null
        }
    }
    $DataStore = $DataStores | Select -First 1
    Return $DataStore
}
