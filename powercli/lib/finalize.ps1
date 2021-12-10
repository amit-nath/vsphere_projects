
function finalize() {
    Write-Host "`n`n#~~~~~~~~~~~~~~~~~~~~~~~~~~~ Teardown ~~~~~~~~~~~~~~~~~~~~~~~~~~~~#"
    Write-Host "# Disconnect from VCENTER $vcenter"
    Write-Host "#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#`n`n"
    Disconnect-VIServer -Confirm:$false
    Write-Host ">>> Successfully disconnected from vcenter`n"
}