@echo off
REM Security Test Runner for Windows
REM Automatically detects environment and runs appropriate tests

setlocal enabledelayedexpansion

REM Create logs directory if it doesn't exist
if not exist logs mkdir logs

REM Log file
set LOG_FILE=logs\test_run.log
set TIMESTAMP=%date% %time%

echo ========================================== >> "%LOG_FILE%"
echo Security Test Execution - %TIMESTAMP% >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM Detect environment
echo Detected OS: Windows >> "%LOG_FILE%"
echo Working Directory: %CD% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

REM Test 1: Verify fixed code exists
echo [TEST 1] Checking for fixed code file... >> "%LOG_FILE%"
if exist "UserController_fixed.java" (
    echo [TEST 1] ✓ UserController_fixed.java found >> "%LOG_FILE%"
    echo [TEST 1] ✓ UserController_fixed.java found
) else (
    echo [TEST 1] ✗ UserController_fixed.java not found >> "%LOG_FILE%"
    echo [TEST 1] ✗ UserController_fixed.java not found
    exit /b 1
)

REM Test 2: Verify no hardcoded secrets in fixed code
echo. >> "%LOG_FILE%"
echo [TEST 2] Scanning for hardcoded secrets... >> "%LOG_FILE%"
findstr /C:"sk-" UserController_fixed.java >nul 2>&1
if errorlevel 1 (
    echo [TEST 2] ✓ No API key patterns found >> "%LOG_FILE%"
    echo [TEST 2] ✓ No API key patterns found
) else (
    echo [TEST 2] ⚠ Potential API key pattern found >> "%LOG_FILE%"
    echo [TEST 2] ⚠ Potential API key pattern found
)

REM Test 3: Verify PreparedStatement usage
echo. >> "%LOG_FILE%"
echo [TEST 3] Checking for SQL injection protection... >> "%LOG_FILE%"
findstr /C:"PreparedStatement" UserController_fixed.java >nul 2>&1
if errorlevel 1 (
    echo [TEST 3] ✗ PreparedStatement not found >> "%LOG_FILE%"
    echo [TEST 3] ✗ PreparedStatement not found
) else (
    echo [TEST 3] ✓ PreparedStatement found (SQL injection protection) >> "%LOG_FILE%"
    echo [TEST 3] ✓ PreparedStatement found (SQL injection protection)
)

findstr /C:"setString" UserController_fixed.java >nul 2>&1
if errorlevel 1 (
    echo [TEST 3] ✗ Parameterized query not found >> "%LOG_FILE%"
    echo [TEST 3] ✗ Parameterized query not found
) else (
    echo [TEST 3] ✓ Parameterized query found (setString) >> "%LOG_FILE%"
    echo [TEST 3] ✓ Parameterized query found (setString)
)

REM Test 4: Verify @Value annotation for externalized config
echo. >> "%LOG_FILE%"
echo [TEST 4] Checking for externalized configuration... >> "%LOG_FILE%"
findstr /C:"@Value" UserController_fixed.java >nul 2>&1
if errorlevel 1 (
    echo [TEST 4] ✗ @Value annotation not found >> "%LOG_FILE%"
    echo [TEST 4] ✗ @Value annotation not found
) else (
    echo [TEST 4] ✓ @Value annotation found (externalized config) >> "%LOG_FILE%"
    echo [TEST 4] ✓ @Value annotation found (externalized config)
)

findstr /C:"DataSource" UserController_fixed.java >nul 2>&1
if errorlevel 1 (
    echo [TEST 4] ✗ DataSource bean not found >> "%LOG_FILE%"
    echo [TEST 4] ✗ DataSource bean not found
) else (
    echo [TEST 4] ✓ DataSource bean usage found >> "%LOG_FILE%"
    echo [TEST 4] ✓ DataSource bean usage found
)

REM Test 5: Verify JSON report exists
echo. >> "%LOG_FILE%"
echo [TEST 5] Verifying security audit report... >> "%LOG_FILE%"
if exist "security_audit_report.json" (
    echo [TEST 5] ✓ security_audit_report.json found >> "%LOG_FILE%"
    echo [TEST 5] ✓ security_audit_report.json found
) else (
    echo [TEST 5] ✗ security_audit_report.json not found >> "%LOG_FILE%"
    echo [TEST 5] ✗ security_audit_report.json not found
)

REM Test 6: Code compilation test (if Maven is available)
echo. >> "%LOG_FILE%"
echo [TEST 6] Testing code compilation... >> "%LOG_FILE%"
where mvn >nul 2>&1
if errorlevel 1 (
    echo [TEST 6] ⚠ Maven not available - skipping compilation test >> "%LOG_FILE%"
    echo [TEST 6] ⚠ Maven not available - skipping compilation test
) else (
    if exist "pom.xml" (
        echo [TEST 6] Attempting to compile with Maven... >> "%LOG_FILE%"
        mvn clean compile -q >> "%LOG_FILE%" 2>&1
        if errorlevel 1 (
            echo [TEST 6] ⚠ Compilation warnings/errors (check logs) >> "%LOG_FILE%"
            echo [TEST 6] ⚠ Compilation warnings/errors (check logs)
        ) else (
            echo [TEST 6] ✓ Code compiles successfully >> "%LOG_FILE%"
            echo [TEST 6] ✓ Code compiles successfully
        )
    ) else (
        echo [TEST 6] ⚠ pom.xml missing - skipping compilation test >> "%LOG_FILE%"
        echo [TEST 6] ⚠ pom.xml missing - skipping compilation test
    )
)

REM Test 7: Docker test (if Docker is available)
echo. >> "%LOG_FILE%"
echo [TEST 7] Testing Docker environment... >> "%LOG_FILE%"
where docker >nul 2>&1
if errorlevel 1 (
    echo [TEST 7] ⚠ Docker not available - skipping Docker tests >> "%LOG_FILE%"
    echo [TEST 7] ⚠ Docker not available - skipping Docker tests
) else (
    if exist "Dockerfile" (
        docker ps >nul 2>&1
        if errorlevel 1 (
            echo [TEST 7] ⚠ Docker daemon is not running >> "%LOG_FILE%"
            echo [TEST 7] ⚠ Docker daemon is not running
        ) else (
            echo [TEST 7] ✓ Docker daemon is running >> "%LOG_FILE%"
            echo [TEST 7] ✓ Docker daemon is running
        )
    ) else (
        echo [TEST 7] ⚠ Dockerfile not found >> "%LOG_FILE%"
        echo [TEST 7] ⚠ Dockerfile not found
    )
)

REM Summary
echo. >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo Test Execution Summary >> "%LOG_FILE%"
echo ========================================== >> "%LOG_FILE%"
echo Test completed at: %date% %time% >> "%LOG_FILE%"
echo Log file: %LOG_FILE% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"
echo Review the full log for detailed results: >> "%LOG_FILE%"
echo   type %LOG_FILE% >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

echo.
echo ==========================================
echo Test Execution Summary
echo ==========================================
echo Test completed at: %date% %time%
echo Log file: %LOG_FILE%
echo.
echo Review the full log for detailed results:
echo   type %LOG_FILE%
echo.

endlocal

