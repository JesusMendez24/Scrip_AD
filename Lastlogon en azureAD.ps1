#Te conectas a Azure AD
Connect-AzAccount
#Sirve para conectar por Microsoft Graph, que sirve para ver los usuarios y las auditorias
Connect-MgGraph -Scopes "User.Read.All"
Connect-MgGraph -Scopes "AuditLog.Read.All"
#Editas la fecha y tambien donde vas a guardar el archivo
Get-MgUser -Filter "signInActivity/LastSignInDateTime le 2023-05-20T00:00:00Z" -Property UserPrincipalName,AccountEnabled,SignInActivity | Where-Object {$_.AccountEnabled -eq $true} | Select-Object UserPrincipalName,@{N="Last SignIn";E={$_.SignInActivity.LastSignInDateTime}},AccountEnabled | Export-Csv -Path C:\Users\ct-jmendez\desktop\Usuarios_inactivos.csv -NoTypeInformation