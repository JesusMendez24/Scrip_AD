## Control de Usuarios
Import-Module ActiveDirectory
Get-ADUser -Filter * -Properties * -ResultPageSize 1000 |  `
    Where-Object {$_.lastlogondate -le (get-date).adddays(-90)} | `
    Select-Object sAMAccountName, givenName, sn, enabled, description, whencreated, lastLogonDate, distinguishedName, PasswordLastSet, PasswordNeverExpires, PasswordNotRequired | `
    Export-Csv -Path $env:HOMEPATH\desktop\$(Get-Date -Format yyyyMMdd)-users.csv -NoTypeInformation

## Control de Maquinas
Import-Module ActiveDirectory
Get-ADComputer -Filter {[DateTime]::FromFileTime($_.LastLogonTimeStamp) -le (Get-Date).Adddays(-90)} -Properties LastLogonTimeStamp | `
    Select-Object Name,@{Name="Stamp";Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}, Enabled | `
    Export-Csv -Path $env:HOMEPATH\desktop\$(Get-Date -Format yyyyMMdd)-computers.csv -NoTypeInformation
    
## Colocamos el politica de ejecucion en remoto para que no pinche por windows.
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

##Valido primero si esta instalado el modulo de AzureADPreview, si esta trato de importarlo, si no esta lo trato de instalar. 
##Tiene un break en cada intento, si falla es porque no pudo hacer alguna de las cosas.
if ( $null -eq ((Get-InstalledModule).Name | Select-String "AzureADPreview") ) {
    Write-Output "[!!] AzureADPreview is not Installed..."
    Write-Output "[!!] Trying to install..."
    try {
        Install-Module AzureADPreview -AllowClobber -Force -Scope CurrentUser
    }
    catch {
        Write-Output "[-] Error while installing AzureADPreview"
        break
    }
} else {
    try {
        Import-Module AzureADPreview        
    }
    catch {
        Write-Output "[-] Error while importing AzureADPreview"
        break
    }
}

##Valido primero si esta instalado el modulo de Microsoft.Graph, si esta trato de importarlo, si no esta lo trato de instalar. 
##Tiene un break en cada intento, si falla es porque no pudo hacer alguna de las cosas y se finaliza.
if ( $null -eq ((Get-InstalledModule).Name | Select-String "Microsoft.Graph") ) {
    Write-Output "[!!] Microsoft.Graph is not Installed..."
    Write-Output "[!!] Trying to install..."
    try {
        Install-Module Microsoft.Graph -AllowClobber -Force -Scope CurrentUser
    }
    catch {
        Write-Output "[-] Error while installing Microsoft.Graph"
        break
    }
} else {
    try {
        Import-Module Microsoft.Graph
    }
    catch {
        Write-Output "[-] Error while importing Microsoft.Graph"
        break
    }
}

##Conexion a Azure AD y despues a los scopes de MSGraph
##Cada intento pide credenciales por el MFA
Connect-AzAccount
Connect-MgGraph -Scopes "User.Read.All"
Connect-MgGraph -Scopes "AuditLog.Read.All"

##Usamos este perfil porque es el unico que anda, el normal tiene un bug hace 2 años...sigue ahi claramente
Select-MgProfile -Name "beta"

##Defino la fecha de hoy como punto de inicio del control. Despues le saco 90 dias a la misma fecha aproximada.
$fecha1 = Get-Date -Format yyyy-MM-ddTHH:mm:ssZ
$fecha2 = (Get-Date).Adddays(-90)

##Defino el output...este hay que cambiarlo, no lo puse como parametro porque es demasiado para esto que ejecutas una vez por mes.
##El output queda en el escritorio del usuario que ejecuta, con la fecha de ejecucion.
$outputfile = "C:\$(Get-date -Format yyyy-MM-dd)-last_logon_date_AAD.csv”

##Extraemos todos los eventos de inicio de sesion. 
##Para esto usamos la $fecha1 como parametro, todo lo anterior es extraido, una fecha por usuario, que es la ultima por registro.
##En el proceso solo dejo las cuentas Habilitadas. Tomo UPN, El last logon del usuario y si esta o no habilitada la cuenta, que es redundante pero bueno.
$auditlogs = Get-MgUser -Filter "signInActivity/lastSignInDateTime le $fecha1" -Property UserPrincipalName,AccountEnabled,SignInActivity | Where-Object {$_.AccountEnabled -eq $true} | Select-Object UserPrincipalName,@{N="Last SignIn";E={$_.SignInActivity.LastSignInDateTime}},AccountEnabled

##Para guardar los registros no compliant
$resultado = @()

##Recorro los eventos y valido fecha por fecha los no compliant. Despues los agrego al $resultado.
foreach ($log in $auditlogs){
    if ($log.'Last SignIn' -le $fecha2) {
        $resultado += $log
    }
}

##Imprimo todos los resultados a un csv para analisis, en el escritorio del usuario.
Write-Output $resultado | Export-Csv -Path $outputfile
