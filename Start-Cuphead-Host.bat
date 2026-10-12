@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Coop-Launcher.ps1" -Role Host
if errorlevel 1 pause
