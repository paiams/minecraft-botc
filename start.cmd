@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
if "%~1"=="" goto all
if /I "%~1"=="all" goto all
if /I "%~1"=="server" goto server
if /I "%~1"=="tunnel" goto tunnel
if /I "%~1"=="demo" goto demo
if /I "%~1"=="--check" goto check
if /I "%~1"=="--help" goto help
echo Unknown command: %1
exit /b 2

:help
echo Usage: start.cmd [all^|server^|tunnel^|demo^|--check^|--help]
echo Default/all: start Minecraft, broadcast, OBS tunnel, and Playit voice tunnel; run again to stop all.
echo Individual services: Ctrl+C stops them. --check only validates files.
exit /b 0

:check
set "BOTC_DIR=%~dp0."
goto check_stack

:all
setlocal EnableDelayedExpansion
set "STACK_PID=%~dp0server\.botc-stack.pid"
set "STOP_FILE=%~dp0server\.botc-stack.stop"
set "BOTC_DIR=%~dp0"
if "%BOTC_DIR:~-1%"=="\" set "BOTC_DIR=%BOTC_DIR:~0,-1%"

if exist "%STACK_PID%" (
    set "MANAGER_PID="
    set /p MANAGER_PID=<"%STACK_PID%"
    if defined MANAGER_PID (
        tasklist /FI "PID eq !MANAGER_PID!" /NH 2>nul | findstr /I /C:"java.exe" >nul
        if not errorlevel 1 (
            >"%STOP_FILE%" echo stop
            echo BotC stack stop requested.
            timeout /t 2 /nobreak >nul
            exit /b 0
        )
    )
    del /q "%STACK_PID%" 2>nul
)

del /q "%STOP_FILE%" 2>nul
java "%~dp0scripts\BotcStack.java" "%BOTC_DIR%"
exit /b %errorlevel%

:check_stack
java "%~dp0scripts\BotcStack.java" "%BOTC_DIR%" --check
exit /b %errorlevel%

:server
cd /d "%~dp0server" || exit /b 1
rem Avoid Java Unix socket failures caused by an 8.3-form TEMP path on Windows.
if not exist ".tmp" mkdir ".tmp"
java "-Djdk.net.unixdomain.tmpdir=%CD%\.tmp" -Xms2G -Xmx4G -jar fabric-server-launch.jar nogui
goto service_done

:demo
set "JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:/Windows/Temp %JAVA_TOOL_OPTIONS%"
call "%~dp0..\minecraft-botc-broadcast\gradlew.bat" -p "%~dp0..\minecraft-botc-broadcast" --no-daemon --no-watch-fs --console=plain demo -Pport=8770
goto service_done

:tunnel
echo Keep this window open while broadcasting. Ctrl+C stops the tunnel.
ssh -n -o BatchMode=yes -o ConnectTimeout=10 kbrp "if ss -xlH | grep -Fq /home/mario/nginx-proxy-manager/data/botc/bridge.sock; then echo OBS tunnel is already running; exit 1; fi; if test -S /home/mario/nginx-proxy-manager/data/botc/bridge.sock; then rm -- /home/mario/nginx-proxy-manager/data/botc/bridge.sock; fi"
if errorlevel 1 (
    set "code=%errorlevel%"
    goto tunnel_failed
)
ssh -n -o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -R /home/mario/nginx-proxy-manager/data/botc/bridge.sock:127.0.0.1:8771 kbrp "chmod 600 /home/mario/nginx-proxy-manager/data/botc/bridge.sock; sleep infinity"
goto service_done

:tunnel_failed
echo Tunnel failed. Check SSH access and whether another tunnel is running.
goto service_finish

:service_done
set "code=%errorlevel%"
:service_finish
if /I "%~2"=="--managed" exit /b %code%
pause
exit /b %code%
