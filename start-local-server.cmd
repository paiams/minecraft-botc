@echo off
cd /d "%~dp0server"
rem Avoid Java Unix socket failures caused by an 8.3-form TEMP path on Windows.
if not exist ".tmp" mkdir ".tmp"
java "-Djdk.net.unixdomain.tmpdir=%CD%\.tmp" -Xms2G -Xmx4G -jar fabric-server-launch.jar nogui
pause
