@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

set "STACK_PID=%~dp0server\.botc-stack.pid"
set "STOP_FILE=%~dp0server\.botc-stack.stop"
set "BOTC_DIR=%~dp0"
if "%BOTC_DIR:~-1%"=="\" set "BOTC_DIR=%BOTC_DIR:~0,-1%"

if /I "%~1"=="--check" goto check

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

:check
java "%~dp0scripts\BotcStack.java" "%BOTC_DIR%" --check
exit /b %errorlevel%
