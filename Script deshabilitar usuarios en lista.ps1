$usuario = "ct-abenza" # Reemplaza "nombre_de_usuario" por el nombre de usuario del que deseas obtener los grupos

$grupos = Get-ADUser -Identity $usuario | Get-ADPrincipalGroupMembership

$grupos | Select-Object -ExpandProperty Name | Out-File -FilePath "C:\Users\ct-jmendez\Desktop\grupos_$usuario.txt"