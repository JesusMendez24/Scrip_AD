# Obtener el nombre del hostname del servidor
$hostname = $env:COMPUTERNAME

# Ruta UNC del destino
$destinationPath = "\\192.168.0.98\Shares\Groups\Secinfo\Servidores"

# Crear una carpeta con el nombre del hostname en el destino
$backupFolder = Join-Path -Path $destinationPath -ChildPath $hostname
New-Item -ItemType Directory -Path $backupFolder -Force

# Obtener los servicios y usuarios
$services = Get-Service | Select-Object Name, RequiredServices, CanPauseAndContinue, CanShutdown, CanStop, DisplayName, DependentServices, MachineName, ServiceName, ServicesDependedOn, ServiceHandle, Status, ServiceType, StartType

foreach ($service in $services) {
    $serviceName = $service.Name
    $username = (Get-WmiObject -Class Win32_Service | Where-Object { $_.Name -eq $serviceName }).StartName
    $service | Add-Member -NotePropertyName "Username" -NotePropertyValue $username
    $service | Add-Member -NotePropertyName "LogOnAs" -NotePropertyValue (Get-WmiObject -Class Win32_Service | Where-Object { $_.Name -eq $serviceName }).StartName
}

# Exportar resultados de servicios y usuarios a un archivo CSV en la carpeta del hostname
$services | Export-Csv -Path "$backupFolder\ServiciosUsuarios.csv" -NoTypeInformation

# Hacer una copia de seguridad de Windows\System32\drivers\etc en la carpeta del hostname
$etcBackupFolder = Join-Path -Path $backupFolder -ChildPath "etc"
Copy-Item -Path "C:\Windows\System32\drivers\etc" -Destination $etcBackupFolder -Recurse

# Obtener información de tamaño y espacio en disco
$diskInfo = Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, MediaType, @{Name="Size (GB)"; Expression={$_.Size / 1GB -as [int]}}, @{Name="FreeSpace (GB)"; Expression={$_.FreeSpace / 1GB -as [int]}}

# Exportar resultados de tamaño y espacio en disco a un archivo CSV en la carpeta del hostname
$diskInfo | Export-Csv -Path "$backupFolder\Espacio_Disco.csv" -NoTypeInformation

# Obtener usuarios locales
$localUsers = Get-LocalUser | Select-Object Name, PrincipalSource, ObjectClass, Enabled

# Obtener grupos locales
$localGroups = Get-LocalGroup

# Obtener miembros del grupo "Administrators"
$administrators = Get-LocalGroupMember -Group "Administrators"

# Exportar usuarios locales a un archivo CSV en la carpeta del hostname
$localUsers | Export-Csv -Path "$backupFolder\UsuariosLocales.csv" -NoTypeInformation

# Exportar grupos locales a un archivo CSV en la carpeta del hostname
$localGroups | Export-Csv -Path "$backupFolder\GruposLocales.csv" -NoTypeInformation

# Exportar miembros del grupo "Administrators" a un archivo CSV en la carpeta del hostname
$administrators | Export-Csv -Path "$backupFolder\MiembrosAdministrators.csv" -NoTypeInformation

Write-Host "Los reportes en formato CSV se han generado correctamente."

# Ejecutar comandos de CMD y guardar los resultados en archivos en la carpeta del hostname
cmd /c netstat -an > "$backupFolder\Puertos.csv"
cmd /c ipconfig /all > "$backupFolder\ip-servidor.csv"
cmd /c icacls "C:\" /T /Q > "$backupFolder\Permisos_file.csv"