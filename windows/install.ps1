# Windows setup: Mac-style keys, Rectangle window shortcuts, Raycast.
# Run from a normal (non-admin) PowerShell:
#   powershell -ExecutionPolicy Bypass -File .\windows\install.ps1
# Safe to run again; it updates what's already there.

$ErrorActionPreference = 'Stop'
$here   = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = Join-Path $here 'mackeys\MacKeys.ahk'

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

Step 'Installing AutoHotkey v2'
winget install --id AutoHotkey.AutoHotkey -e --silent --accept-source-agreements --accept-package-agreements --disable-interactivity
$ahk = @(
    "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $ahk) { throw 'AutoHotkey64.exe not found after install.' }

Step 'Installing Raycast (Microsoft Store)'
winget install --id 9PFXXSHC64H3 -s msstore --silent --accept-source-agreements --accept-package-agreements --disable-interactivity

Step 'Checking the key script'
$p = Start-Process $ahk -ArgumentList '/ErrorStdOut', '/validate', "`"$script`"" -Wait -PassThru -NoNewWindow
if ($p.ExitCode -ne 0) { throw "MacKeys.ahk has a syntax error (exit $($p.ExitCode))." }

Step 'Registering the MacKeys task (starts at login, relaunches within a minute if it stops)'
$user      = "$env:USERDOMAIN\$env:USERNAME"
$action    = New-ScheduledTaskAction -Execute $ahk -Argument "`"$script`"" -WorkingDirectory (Split-Path $script)
$atLogon   = New-ScheduledTaskTrigger -AtLogOn -User $user
$everyMin  = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 1)
$settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable `
               -MultipleInstances IgnoreNew -ExecutionTimeLimit ([TimeSpan]::Zero) `
               -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1)
$principal = New-ScheduledTaskPrincipal -UserId $user -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName 'MacKeys' -Description 'Mac-style keys + Rectangle shortcuts (AutoHotkey).' `
    -Action $action -Trigger $atLogon, $everyMin -Settings $settings -Principal $principal -Force | Out-Null

# An older setup used a Startup-folder shortcut; the task replaces it.
$lnk = Join-Path ([Environment]::GetFolderPath('Startup')) 'MacKeys.lnk'
if (Test-Path $lnk) { Move-Item $lnk "$lnk.disabled" -Force }

Get-Process AutoHotkey64 -ErrorAction SilentlyContinue | Stop-Process -Force
Start-ScheduledTask -TaskName 'MacKeys'

Write-Host @"

Done. MacKeys is running.

Finish by hand (these apps keep their settings where a script can't reach):
  1. Keychron: set the side switch to WINDOWS.
  2. Raycast > Settings > General > Raycast Hotkey = Ctrl+Shift+Space
     (pause MacKeys first: tray icon > Suspend Hotkeys; resume after).
  3. PowerToys > Keyboard Manager: no Caps Lock remap (MacKeys handles it).
  4. Willow Voice: keep its Ctrl+Alt shortcut (real Ctrl + Option starts dictation).

See windows/README.md for the full key map.
"@ -ForegroundColor Green
