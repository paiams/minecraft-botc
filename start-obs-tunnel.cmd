@echo off
setlocal
echo Keep this window open while broadcasting. Ctrl+C stops the tunnel.
ssh -n -o BatchMode=yes -o ConnectTimeout=10 kbrp "if ss -xlH | grep -Fq /home/mario/nginx-proxy-manager/data/botc/bridge.sock; then echo OBS tunnel is already running; exit 1; fi; if test -S /home/mario/nginx-proxy-manager/data/botc/bridge.sock; then rm -- /home/mario/nginx-proxy-manager/data/botc/bridge.sock; fi"
if errorlevel 1 (
    set "code=%errorlevel%"
    goto failed
)
ssh -n -o BatchMode=yes -o ExitOnForwardFailure=yes -o ServerAliveInterval=15 -o ServerAliveCountMax=3 -R /home/mario/nginx-proxy-manager/data/botc/bridge.sock:127.0.0.1:8771 kbrp "chmod 600 /home/mario/nginx-proxy-manager/data/botc/bridge.sock; sleep infinity"
set "code=%errorlevel%"
goto done
:failed
if not "%code%"=="0" echo Tunnel failed. Check SSH access and whether another tunnel is running.
:done
if /I "%~1"=="--managed" exit /b %code%
pause
exit /b %code%
