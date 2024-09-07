@echo off
setlocal enabledelayedexpansion

set SERVER_DIR=%~dp0
set PID_FILE=%SERVER_DIR%server.pid
set LOG_FILE=%SERVER_DIR%server.log
set DEBUG_LOG=%SERVER_DIR%debug.log

echo %date% %time% - Script started with parameter: %1 >> "%DEBUG_LOG%"

if "%1"=="start" (
    call :start_server
) else if "%1"=="stop" (
    call :stop_server
) else (
    echo %date% %time% - Invalid command. Use "start" or "stop". >> "%DEBUG_LOG%"
    echo Usage: %0 [start^|stop]
)

goto :eof

:start_server
echo %date% %time% - Starting server... >> "%DEBUG_LOG%"
cd /d "%SERVER_DIR%"
echo %date% %time% - Changed directory to %SERVER_DIR% >> "%DEBUG_LOG%"

if exist "%PID_FILE%" (
    set /p EXISTING_PID=<"%PID_FILE%"
    tasklist /FI "PID eq !EXISTING_PID!" 2>NUL | find /I /N "node.exe">NUL
    if "!ERRORLEVEL!"=="0" (
        echo %date% %time% - Server is already running with PID !EXISTING_PID! >> "%DEBUG_LOG%"
        goto :eof
    ) else (
        echo %date% %time% - Removing stale PID file >> "%DEBUG_LOG%"
        del "%PID_FILE%"
    )
)

start /b "" node server.js > "%LOG_FILE%" 2>&1
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq node.exe" /fo list /v ^| find /i "PID:"') do (
    echo %%i > "%PID_FILE%"
    echo %date% %time% - Server started with PID %%i >> "%DEBUG_LOG%"
    goto :eof
)
goto :eof

:stop_server
if exist "%PID_FILE%" (
    set /p PID=<"%PID_FILE%"
    echo %date% %time% - Stopping server with PID !PID!... >> "%DEBUG_LOG%"
    taskkill /PID !PID! /F
    if !ERRORLEVEL! equ 0 (
        del "%PID_FILE%"
        echo %date% %time% - Server stopped successfully >> "%DEBUG_LOG%"
    ) else (
        echo %date% %time% - Failed to stop server. It may have already been stopped. >> "%DEBUG_LOG%"
    )
) else (
    echo %date% %time% - PID file not found. Server might not be running. >> "%DEBUG_LOG%"
)
goto :eof