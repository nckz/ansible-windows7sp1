# Getting PARADISE Ready for Ansible
The final goal of these steps is to get the Ansible configuration script
(ConfigureRemotingForAnsible.ps1 -Verbose) to complete successfully.  And to
run a successful Ansible win_ping.

1. Run the Repair script (required to install .NET and WMF)
 * https://answers.microsoft.com/en-us/windows/forum/windows_7-security/80070422-errorservicedisabled-the-service-cannot/ce05b449-248b-48a9-89f7-e3ef2c147c68
2. Install .NET 4.5 (required by WMF-installer :@ )
 * dotNetFx45_Full_setup.exe
3. Install WMF 4.0 (powershell 4)
 * Windows6.1-KB2819745-x64-MultiPkg.msu
4. Set all networks to private interfaces:
 * cmd: start_stop_procs.pl stop
 * disable all network adapters except the "hospital connection"
   * and disable the loopback connection since it wants to be labeled "public"
5. Start WinRM
 * powershell: winrm quickconfig
   * answered 'yes'
6. Change the Windows Remote Shell setting to on/true
 * Start, searchbox: gpedit.msc, Enter
 * 
 * http://superuser.com/questions/1051813/how-to-properly-set-the-allow-remote-shell-access-setting-in-group-policy-so-a

n. Check WinRM Config
 * powershell: winrm get wimrm/config
 * should look like this:

 * Run the Ansible Config Script -Verbose
 * undo all security settings:
 http://www.hurryupandwait.io/blog/understanding-and-troubleshooting-winrm-connection-and-authentication-a-thrill-seekers-guide-to-adventure
 * Change the Computer Name to R530CDAS203
 * make it bonjour accessible
 * netplwiz
 * set max memory per shell and max procs per shell 
  https://social.technet.microsoft.com/Forums/office/en-US/4d6e99ab-970f-4616-b53d-2b44e56caf16/not-enough-quota-is-available-to-process-this-command?forum=winserverpowershell

