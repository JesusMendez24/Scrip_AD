# Nombre del grupo de Active Directory
$groupName = "APP-MVDQ-JEFE_EQUIPO"

# Obtener información del grupo
$group = Get-ADGroup $groupName -Properties Members

# Obtener miembros del grupo
$groupMembers = $group.Members

# Crear una lista para almacenar la información de los miembros
$memberList = @()

# Recorrer la lista de miembros y agregar la información al array
$groupMembers | ForEach-Object {
    $user = Get-ADUser $_
    $memberList += [PSCustomObject]@{
        Name = $user.Name
        UserPrincipalName = $user.UserPrincipalName
    }
}

# Ruta del archivo CSV
$csvPath = "C:\Users\ct-jmendez\Desktop\miembros_grupo.csv"

# Exportar la información a un archivo CSV
$memberList | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Archivo CSV exportado con éxito a: $csvPath"
