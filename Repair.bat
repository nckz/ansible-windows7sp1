::: Before installing PowerShell updates run this batch file from:
:::     https://answers.microsoft.com/en-us/windows/forum/windows_7-security/80070422-errorservicedisabled-the-service-cannot/ce05b449-248b-48a9-89f7-e3ef2c147c68
::: Then install the .NET 4.5 Framework from here:
:::     https://www.microsoft.com/en-us/download/confirmation.aspx?id=30653
::: Then install the Windows Management Framework 4.0 (which has powershell)
:::     https://social.technet.microsoft.com/wiki/contents/articles/21016.how-to-install-windows-powershell-4-0.aspx#Windows_Management_Framework_4_supportability_matrix
sc config wuauserv start= auto
sc config bits start= auto
sc config DcomLaunch start= auto
net stop wuauserv
net start wuauserv
net stop bits
net start bits
net start DcomLaunch
