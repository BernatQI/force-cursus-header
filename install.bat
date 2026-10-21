@echo off
REM ============================================================================
REM 42 Intra - Force 42cursus Header | Windows Launcher (Double-click / CMD)
REM ============================================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" %*
pause
