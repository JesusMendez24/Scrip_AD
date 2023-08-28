# Conectar al servicio de Microsoft Online Services
Connect-MsolService

# Obtener la lista de usuarios con MFA habilitado
$usersWithMFA = Get-MsolUser -All | Where-Object { $_.StrongAuthenticationRequirements.Count -gt 0 }

# Ruta del archivo CSV
$csvPath = "C:\Users\ct-jmendez\Desktop\usuarios_mfa_habilitado.csv"

# Crear un objeto para la información de usuarios con MFA habilitado
$usersWithMFAInfo = $usersWithMFA | Select-Object DisplayName, UserPrincipalName

# Exportar la información a un archivo CSV
$usersWithMFAInfo | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Archivo CSV exportado con éxito a: $csvPath"
