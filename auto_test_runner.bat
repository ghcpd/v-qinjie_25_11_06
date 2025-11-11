@echo off
REM Universal Test Runner for Windows - Auto-detects environment and runs tests

setlocal enabledelayedexpansion

REM Create logs directory
if not exist logs mkdir logs

set LOG_FILE=logs\test_run.log
set TIMESTAMP=%date% %time%

echo ========================================== >> "%LOG_FILE%"
echo Automatic Security Test Runner >> "%LOG_FILE%"
echo Started: %TIMESTAMP% >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM Detect environment
echo Detected OS: Windows >> "%LOG_FILE%"
echo Environment: Windows Native >> "%LOG_FILE%"

REM Check if running in Docker (Windows containers)
docker info >nul 2>&1
if errorlevel 1 (
    echo Not running in Docker container >> "%LOG_FILE%"
) else (
    echo Running in Docker environment >> "%LOG_FILE%"
)

REM Run Windows test script
if exist "run_test.bat" (
    call run_test.bat
) else (
    echo Error: run_test.bat not found >> "%LOG_FILE%"
    echo Error: run_test.bat not found
    exit /b 1
)

echo. >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo Test execution completed >> "%LOG_FILE%"
echo Log saved to: %LOG_FILE% >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"

endlocal

