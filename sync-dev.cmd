@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\sync_dev.ps1" %*
set "sync_result=%ERRORLEVEL%"
if not "%sync_result%"=="0" echo Synchronization failed. See the error above.
pause
exit /b %sync_result%
