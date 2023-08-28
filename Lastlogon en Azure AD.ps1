Connect-MgGraph -Scopes "User.Read.All"
Connect-MgGraph -Scopes "AuditLog.Read.All"
Select-MgProfile -Name "beta"
$fecha1 = Get-Date -Format yyyy-MM-ddTHH:mm:ssZ
$fecha2 = (Get-Date).Adddays(-60)
$outputfile = "C:\Ruta\$(Get-date -Format yyyy-MM-dd)-last_logon_date_AAD.csv”
$auditlogs = Get-MgUser -Filter "signInActivity/lastSignInDateTime le $fecha1" -Property UserPrincipalName,AccountEnabled,SignInActivity | Where-Object {$_.AccountEnabled -eq $true} | Select-Object UserPrincipalName,@{N="Last SignIn";E={$_.SignInActivity.LastSignInDateTime}},AccountEnabled
$resultado = @()
foreach ($log in $auditlogs){
    if ($log.'Last SignIn' -le $fecha2) {
        $resultado += $log
    }
}
Write-Output $resultado | Export-Csv -Path $outputfile