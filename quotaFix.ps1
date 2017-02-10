#Requires -Version 3.0

winrm set winrm/config/winrs '@{MaxProcessesPerShell="10000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="8000"}'
