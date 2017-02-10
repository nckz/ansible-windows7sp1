#Requires -Version 3.0

# Increase the number of allowed processes per remote session to 10,000.
# Increase the allowed memory usage to 8GB.
winrm set winrm/config/winrs '@{MaxProcessesPerShell="10000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="8000"}'
