$computers = Get-ADComputer -Filter *
$domain = "latam.com"
$username = "ct-ealba"

foreach ($computer in $computers) {
    $computerName = $computer.Name
    $group = [ADSI]"WinNT://$computerName/Administrators,group"
    $members = $group.Invoke("Members") | foreach { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) }
    
    if ($members -contains $username) {
        Write-Host "El usuario $username es administrador en $computerName"
    } else {
        Write-Host "El usuario $username NO es administrador en $computerName"
    }
}
