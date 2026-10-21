# ==============================================================================
# 42 Intra - Force 42cursus Header | Windows Uninstaller (PowerShell)
# ==============================================================================

$ErrorActionPreference = "Stop"

$InstallBaseDir = Join-Path $env:LOCALAPPDATA "force-cursus-header"
$DesktopDir = [Environment]::GetFolderPath("Desktop")

Write-Host "=== Uninstalling 42 Intra - Force 42cursus Header (Windows) ===" -ForegroundColor Cyan

if (Test-Path $DesktopDir) {
    $WshShell = New-Object -ComObject WScript.Shell
    $lnkFiles = Get-ChildItem -Path $DesktopDir -Filter "*.lnk" -ErrorAction SilentlyContinue
    foreach ($lnk in $lnkFiles) {
        try {
            $shortcut = $WshShell.CreateShortcut($lnk.FullName)
            if ($shortcut.Arguments -match "force-cursus-header") {
                $shortcut.Arguments = ($shortcut.Arguments -replace '--disable-features=DisableLoadExtensionCommandLineSwitch\s*', '' -replace '--load-extension="[^"]*force-cursus-header\\extension"', '').Trim()
                $shortcut.Save()
                Write-Host "[OK] Restored shortcut: $($lnk.FullName)" -ForegroundColor Green
            }
        } catch {}
    }
}

if (Test-Path $InstallBaseDir) {
    Remove-Item -Path $InstallBaseDir -Recurse -Force
    Write-Host "[OK] Removed directory: $InstallBaseDir" -ForegroundColor Green
}

Write-Host "=== Uninstallation Completed ===" -ForegroundColor Green
