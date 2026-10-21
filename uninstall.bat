@echo off
REM ============================================================================
REM 42 Intra - Force 42cursus Header | Windows Uninstaller Launcher
REM ============================================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall.ps1" %*
pause
