@echo off
REM auto_test.bat - Automatic environment detection and test execution

echo Automatic Security Test Runner
echo ===============================

REM Create logs directory if it doesn't exist
if not exist logs mkdir logs

REM Detect environment and run appropriate test
echo Detecting environment... > logs\auto_test.log

if exist "%WINDIR%" (
    echo Windows environment detected >> logs\auto_test.log
    echo Running Windows test script... >> logs\auto_test.log
    call run_test.bat
) else (
    echo Non-Windows environment detected >> logs\auto_test.log
    echo Please use auto_test.sh for Linux/macOS >> logs\auto_test.log
)

echo.
echo Auto test execution completed.
echo Check logs\auto_test.log and logs\test_run.log for details.
pause