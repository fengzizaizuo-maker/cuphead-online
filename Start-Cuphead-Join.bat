@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Coop-Launcher.ps1" -Role Join
if errorlevel 1 pause
