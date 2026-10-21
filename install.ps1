# ==============================================================================
# 42 Intra - Force 42cursus Header | Windows Auto-Installer (PowerShell)
# Detects Chrome, Brave, Edge, Chromium, and Firefox on Windows, installs the
# extension into %LOCALAPPDATA%\force-cursus-header, and copies the path to the
# Windows clipboard.
# Executes 100% on the main thread (no Start-Job, no recursive .lnk traversal)
# to prevent StackOverflowException in Windows PowerShell 5.1.
# ==============================================================================

param(
    [switch]$NoBrowser,
    [switch]$PatchShortcuts
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InstallBaseDir = Join-Path $env:LOCALAPPDATA "force-cursus-header"
$ExtInstallDir = Join-Path $InstallBaseDir "extension"
$UserscriptInstallPath = Join-Path $InstallBaseDir "force-42cursus-header.user.js"

Write-Host "=== 42 Intra - Force 42cursus Header (Windows Auto-Installer) ===" -ForegroundColor Cyan

# 1. Copy files to %LOCALAPPDATA%\force-cursus-header
New-Item -ItemType Directory -Force -Path $ExtInstallDir | Out-Null
Copy-Item -Path (Join-Path $ScriptDir "extension\*") -Destination $ExtInstallDir -Recurse -Force
Copy-Item -Path (Join-Path $ScriptDir "userscript\force-42cursus-header.user.js") -Destination $UserscriptInstallPath -Force

Write-Host "[OK] Files installed in: $InstallBaseDir" -ForegroundColor Green

# Copy extension path to Windows clipboard
try {
    Set-Clipboard -Value $ExtInstallDir
    Write-Host "[OK] Path '$ExtInstallDir' copied to Windows clipboard (Ctrl+V)." -ForegroundColor Green
} catch {}

# 2. Detect installed browsers on Windows
$BrowserCandidates = @(
    @{ Name = "Google Chrome"; Family = "Chromium"; Exe = "chrome.exe"; Paths = @(
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
    )},
    @{ Name = "Brave Browser"; Family = "Chromium"; Exe = "brave.exe"; Paths = @(
        "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe",
        "${env:ProgramFiles(x86)}\BraveSoftware\Brave-Browser\Application\brave.exe",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe"
    )},
    @{ Name = "Microsoft Edge"; Family = "Chromium"; Exe = "msedge.exe"; Paths = @(
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
        "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe"
    )},
    @{ Name = "Chromium"; Family = "Chromium"; Exe = "chrome.exe"; Paths = @(
        "$env:ProgramFiles\Chromium\Application\chrome.exe",
        "$env:LOCALAPPDATA\Chromium\Application\chrome.exe"
    )},
    @{ Name = "Mozilla Firefox"; Family = "Firefox"; Exe = "firefox.exe"; Paths = @(
        "$env:ProgramFiles\Mozilla Firefox\firefox.exe",
        "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe",
        "$env:LOCALAPPDATA\Mozilla Firefox\firefox.exe"
    )}
)

$DetectedBrowsers = @()
Write-Host "`nScanning for installed browsers on Windows..." -ForegroundColor Cyan

foreach ($candidate in $BrowserCandidates) {
    foreach ($p in $candidate.Paths) {
        if ($p -and (Test-Path $p)) {
            Write-Host "[Detected] $($candidate.Name) ($p)" -ForegroundColor Green
            $DetectedBrowsers += @{
                Name   = $candidate.Name
                Family = $candidate.Family
                Exe    = $candidate.Exe
                Path   = $p
            }
            break
        }
    }
}

# 3. Optional (-PatchShortcuts): Update Desktop .lnk shortcuts without deep recursion
$ExtArgs = "--load-extension=`"$ExtInstallDir`""
if ($PatchShortcuts) {
    $DesktopDir = [Environment]::GetFolderPath("Desktop")
    if (Test-Path $DesktopDir) {
        $WshShell = New-Object -ComObject WScript.Shell
        $lnkFiles = Get-ChildItem -Path $DesktopDir -Filter "*.lnk" -ErrorAction SilentlyContinue
        foreach ($lnk in $lnkFiles) {
            try {
                $shortcut = $WshShell.CreateShortcut($lnk.FullName)
                if ($shortcut.TargetPath -match "(chrome|brave|msedge)\.exe$") {
                    if ($shortcut.Arguments -notmatch "force-cursus-header") {
                        $shortcut.Arguments = "$($shortcut.Arguments) $ExtArgs".Trim()
                        $shortcut.Save()
                        Write-Host "[OK] Updated shortcut: $($lnk.FullName)" -ForegroundColor Green
                    }
                }
            } catch {}
        }
    }
}

# 4. Serve the .user.js file on the main thread (no Start-Job) and launch browser
if (-not $NoBrowser -and $DetectedBrowsers.Count -gt 0) {
    Write-Host "`nOpening installer in detected browsers..." -ForegroundColor Cyan
    $Port = 18742
    $UserscriptUrl = "http://127.0.0.1:$Port/force-42cursus-header.user.js"

    $listener = $null
    try {
        $listener = New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://127.0.0.1:$Port/")
        $listener.Start()

        $OpenedChromium = $false
        foreach ($b in $DetectedBrowsers) {
            if ($b.Family -eq "Firefox") {
                Start-Process -FilePath $b.Path -ArgumentList $UserscriptUrl
            } elseif ($b.Family -eq "Chromium" -and -not $OpenedChromium) {
                Start-Process -FilePath $b.Path -ArgumentList "$ExtArgs `"$UserscriptUrl`""
                $OpenedChromium = $true
            }
        }

        Write-Host "[i] Serving Userscript locally for 6 seconds at '$UserscriptUrl'..." -ForegroundColor Yellow
        $endTime = (Get-Date).AddSeconds(6)
        $bytes = [System.IO.File]::ReadAllBytes($UserscriptInstallPath)
        while ((Get-Date) -lt $endTime) {
            $async = $listener.BeginGetContext($null, $null)
            if ($async.AsyncWaitHandle.WaitOne(1000)) {
                $context = $listener.EndGetContext($async)
                if ($context.Request.Url.AbsolutePath -eq "/force-42cursus-header.user.js") {
                    $context.Response.StatusCode = 200
                    $context.Response.ContentType = "application/javascript; charset=utf-8"
                    $context.Response.ContentLength64 = $bytes.Length
                    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
                } else {
                    $context.Response.StatusCode = 404
                }
                $context.Response.OutputStream.Close()
            }
        }
    } catch {
        # Fallback if port is already bound
    } finally {
        if ($null -ne $listener -and $listener.IsListening) {
            $listener.Stop()
        }
    }
}

Write-Host "`n=== Windows Installation Completed ===" -ForegroundColor Green
Write-Host "  • Extension folder (copied to clipboard): $ExtInstallDir"
Write-Host "  • In Chrome/Brave/Edge: open chrome://extensions -> 'Developer mode' -> 'Load unpacked' -> paste path with Ctrl+V."
