# Installing Ansible on Windows 7 SP1
The final goal of this guide is to get the Ansible configuration script
(ConfigureRemotingForAnsible.ps1) to complete successfully.  And to run a
successful Ansible win_ping.

**These instructions are NOT for a production server.  This is just to get
Ansible up and running. This setup should be performed on a secure private
network.**

## 1. Install .NET 4.5 (required by WMF-installer :@ )
Download the .NET 4.5 [dotNetFx45_Full_setup.exe](https://www.microsoft.com/en-us/download/confirmation.aspx?id=30653) from microsoft.com, then install.

If this doesn't install checkout step 1.a, else move on to step 2.
 
### 1.a Run the Repair script (required to install .NET)
I wasn't able to install the .NET framework directly because I kept getting an
error that looked like this:

> 80070422 ERROR_SERVICE_DISABLED. The service cannot be started, either because it is disabled or because__it has no enabled devices associated with it.

Luckily Google found a post with a solution from the [MS Forum](https://answers.microsoft.com/en-us/windows/forum/windows_7-security/80070422-errorservicedisabled-the-service-cannot/ce05b449-248b-48a9-89f7-e3ef2c147c68) which offered the `Repair.bat` script as a solution.  I don't know what this does, but Google top hits are as follows:

1. `wuauserv` is related to "Windows Update".
2. `bits` is the "Background Intelligent Service" used to download windows updates.
3. `DcomLaunch` is a service that confirms signature of windows files.

It seems the script sets these services to auto-start, perhaps.

In an Administrator command window run:

```
> .\Repair.bat
```

## 3. Install WMF 4.0 (powershell 4)
Download the Windows Management Framework
[Windows6.1-KB2819745-x64-MultiPkg.msu](https://social.technet.microsoft.com/wiki/contents/articles/21016.how-to-install-windows-powershell-4-0.aspx#Windows_Management_Framework_4_supportability_matrix)
from social.technet.microsoft.com, and install it.  After the reboot, check for
the correct PowerShell version by entering:
```
> $PSVersionTable
...
PSVersion           4.0
...
```

## 4. Set All Networks to Private Interfaces
Stop all programs that are using a network interface.  If your on a PARADISE
environment then issue the:
```
 start_stop_procs.pl stop
```
in a command window.

Disable all network adapters in the `Network and Sharing Center` off of the
`Control Panel` (in PARADISE leave the "Hospital Connection" on if its set to
"private"). Also disable the loopback connection if necessary (if its labeled
"public").

When you toggle them back on, Windows will ask what type of network they're
connected to; select "private" or "home", etc...

## 5. Start WinRM
 * powershell: winrm quickconfig
   * answered 'y' to:
   1. Set WinRM service type to dealyed auto start?
   2. Create a WinRM listener on HTTP://* ....?

## 6. Change the Windows Remote Shell Setting to enabled/true
 * From [superuser.com](http://superuser.com/questions/1051813/how-to-properly-set-the-allow-remote-shell-access-setting-in-group-policy-so-a), Hit 'Start', in the searchbox enter `gpedit.msc` then press 'Enter'.
 * Find and click the "Computer Configuration"->"Administrative Templates"->"Windows Components"->"Windows Remote Shell" by drilling down into the folder structure on the left panel.
 * Double Click the "Allow Remote Shell Access" policy and then check `enabled` in the box on the left.
 * Click "OK" to accept the changes.

## 7. Run the Ansible Config Script
The script can be found on the Ansible [Windows Support](http://docs.ansible.com/ansible/intro_windows.html#windows-system-prep) page. Run download and run this script in a
PowerShell with the 'Verbose' flag.
```
> ConfigureRemotingForAnsible.ps1 -Verbose
...
PS C:\Users\me\Desktop\ansible-windows7sp1> .\ConfigureRemotingForAnsible.ps1 -Verbose
VERBOSE: Verifying WinRM service.
VERBOSE: PS Remoting is already enabled.
VERBOSE: SSL listener is already active.
VERBOSE: Basic auth is already enabled.
VERBOSE: Firewall rule already exists to allow WinRM HTTPS.
VERBOSE: HTTP: Disabled | HTTPS: Enabled
VERBOSE: PS Remoting has been successfully configured for Ansible.
```

## 7. Check the WinRM Config
In a PowerShell, enter the following command and you should see this as the
output:

```
> winrm get winrm/config
...
PS C:\Users\me> winrm get winrm/config
Config
    MaxEnvelopeSizekb = 500
    MaxTimeoutms = 60000
    MaxBatchItems = 32000
    MaxProviderRequests = 4294967295
    Client
        NetworkDelayms = 5000
        URLPrefix = wsman
        AllowUnencrypted = false
        Auth
            Basic = true
            Digest = true
            Kerberos = true
            Negotiate = true
            Certificate = true
            CredSSP = false
        DefaultPorts
            HTTP = 5985
            HTTPS = 5986
        TrustedHosts
    Service
        RootSDDL = O:NSG:BAD:P(A;;GA;;;BA)(A;;GR;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)
        MaxConcurrentOperations = 4294967295
        MaxConcurrentOperationsPerUser = 1500
        EnumerationTimeoutms = 240000
        MaxConnections = 300
        MaxPacketRetrievalTimeSeconds = 120
        AllowUnencrypted = false
        Auth
            Basic = true
            Kerberos = true
            Negotiate = true
            Certificate = false
            CredSSP = false
            CbtHardeningLevel = Relaxed
        DefaultPorts
            HTTP = 5985
            HTTPS = 5986
        IPv4Filter = *
        IPv6Filter = *
        EnableCompatibilityHttpListener = false
        EnableCompatibilityHttpsListener = false
        CertificateThumbprint
        AllowRemoteAccess = true
    Winrs
        AllowRemoteShellAccess = true [Source="GPO"]
        IdleTimeout = 7200000
        MaxConcurrentUsers = 10
        MaxShellRunTime = 2147483647
        MaxProcessesPerShell = 25
        MaxMemoryPerShellMB = 1024
        MaxShellsPerUser = 30
```
# 8. Upping Remote Shell Resource Limits
If your trying to use a Windows VM as part of your build chain, like me, you'll
want to go ahead and increase the memory and number-of-processes quota.  To do
this, enter the following commands (via [social.technet.microsoft.com](https://social.technet.microsoft.com/Forums/office/en-US/4d6e99ab-970f-4616-b53d-2b44e56caf16/not-enough-quota-is-available-to-process-this-command?forum=winserverpowershell)) in the PowerShell:

```
winrm set winrm/config/winrs '@{MaxProcessesPerShell="10000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="8000"}'
```

This will allow the sessions to take up to 8GB of memory and 10,000 processes.

# 9. Install Bonjour Print Services for Zeroconf
I like to use a domain name instead of IP addresses, especially when testing a
setup.  This allows you to use the .local zeroconf tld on your test network in
conjuction with your computer's name. The Ansible example included in this repo
uses `win1.local`. To change your computer's name follow these instructions from
[kb.iu.edu](https://kb.iu.edu/d/ajnx).  To install Bonjour, download the binary
from [support.apple.com](https://support.apple.com/kb/dl999?locale=en_US).

# 10. Ansible Test
The `test.yml` is a simple test from [docs.ansible.com](https://raw.githubusercontent.com/ansible/ansible-examples/master/windows/test.yml), that simply runs an ip
check and a file stat. The one included here has the hosts changed to
'windows'.  Before running the `run_test.sh`, modify the `HOSTS` file with
the user-name and password that you plan to start a remote session with in your
windows machine. It is *required* that the user has a password.

# Bonus References
In addition the links I've used above, these posts were very useful for
understanding why some settings are unsafe and how to turn those settings on.

1. http://www.hurryupandwait.io/blog/understanding-and-troubleshooting-winrm-connection-and-authentication-a-thrill-seekers-guide-to-adventure
2. http://www.hurryupandwait.io/blog/safely-running-windows-automation-operations-that-typically-fail-over-winrm-or-powershell-remoting
