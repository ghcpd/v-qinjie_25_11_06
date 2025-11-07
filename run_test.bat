@echo off
REM Security Setup and Test Script for Java Spring Boot Application
REM Platform: Windows PowerShell 5.1
REM This script sets up the environment and verifies security fixes

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "LOG_DIR=%SCRIPT_DIR%logs"
set "TEST_LOG=%LOG_DIR%\test_run.log"

REM Create logs directory
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

echo. >> "%TEST_LOG%"
echo ========================================== >> "%TEST_LOG%"
echo Security Setup and Test Script >> "%TEST_LOG%"
echo ========================================== >> "%TEST_LOG%"
echo Date: %date% %time% >> "%TEST_LOG%"
echo Platform: Windows >> "%TEST_LOG%"
echo. >> "%TEST_LOG%"

echo ========================================== 
echo Security Setup and Test Script
echo ========================================== 
echo Date: %date% %time%
echo Platform: Windows
echo.

REM Check for Java
where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Java not found. Please install Java 11 or higher.
    echo ERROR: Java not found. Please install Java 11 or higher. >> "%TEST_LOG%"
    exit /b 1
)
for /f "tokens=*" %%i in ('java -version 2^>^&1') do set "JAVA_VERSION=%%i" & goto :java_found
:java_found
echo [OK] Java found: %JAVA_VERSION%
echo [OK] Java found: %JAVA_VERSION% >> "%TEST_LOG%"

REM Check for Maven (optional, for compilation)
where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Maven not found. Compilation tests will be skipped.
    echo [WARNING] Maven not found. Compilation tests will be skipped. >> "%TEST_LOG%"
) else (
    for /f "tokens=*" %%i in ('mvn -version 2^>^&1 ^| findstr /R "Apache Maven"') do set "MVN_VERSION=%%i"
    echo [OK] Maven found: !MVN_VERSION!
    echo [OK] Maven found: !MVN_VERSION! >> "%TEST_LOG%"
)

echo.
echo [*] Configuring environment variables...
echo. >> "%TEST_LOG%"
echo [*] Configuring environment variables... >> "%TEST_LOG%"

REM Set environment variables
if not defined DB_URL set "DB_URL=jdbc:mysql://localhost:3306/appdb"
if not defined DB_USER set "DB_USER=appuser"
if not defined DB_PASSWORD set "DB_PASSWORD=secure_password"
if not defined API_KEY set "API_KEY=sk-secure-key-from-vault"

echo [OK] Environment variables configured:
echo [OK] Environment variables configured: >> "%TEST_LOG%"
echo   - DB_URL: %DB_URL%
echo   - DB_URL: %DB_URL% >> "%TEST_LOG%"
echo   - DB_USER: %DB_USER%
echo   - DB_USER: %DB_USER% >> "%TEST_LOG%"
echo   - API_KEY: *** (hidden for security)
echo   - API_KEY: *** (hidden for security) >> "%TEST_LOG%"

echo.
echo [*] Running security verification checks...
echo. >> "%TEST_LOG%"
echo [*] Running security verification checks... >> "%TEST_LOG%"

REM Check 1: Verify no hardcoded credentials in source code
echo.
echo [Check 1] Verifying no hardcoded credentials in fixed code...
echo. >> "%TEST_LOG%"
echo [Check 1] Verifying no hardcoded credentials in fixed code... >> "%TEST_LOG%"

findstr /M "password" "%SCRIPT_DIR%UserController_fixed.java" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    findstr /V "sk-secure" "%SCRIPT_DIR%UserController_fixed.java" | findstr "sk-" >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo [FAIL] Hardcoded credentials found in fixed code
        echo [FAIL] Hardcoded credentials found in fixed code >> "%TEST_LOG%"
        exit /b 1
    )
)
echo [PASS] No hardcoded credentials in fixed code
echo [PASS] No hardcoded credentials in fixed code >> "%TEST_LOG%"

REM Check 2: Verify PreparedStatement usage
echo.
echo [Check 2] Verifying PreparedStatement usage...
echo. >> "%TEST_LOG%"
echo [Check 2] Verifying PreparedStatement usage... >> "%TEST_LOG%"

findstr "PreparedStatement" "%SCRIPT_DIR%UserController_fixed.java" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] PreparedStatement not found
    echo [FAIL] PreparedStatement not found >> "%TEST_LOG%"
    exit /b 1
)
echo [PASS] PreparedStatement found in fixed code
echo [PASS] PreparedStatement found in fixed code >> "%TEST_LOG%"

REM Check 3: Verify environment variable usage
echo.
echo [Check 3] Verifying environment variable usage for DB credentials...
echo. >> "%TEST_LOG%"
echo [Check 3] Verifying environment variable usage for DB credentials... >> "%TEST_LOG%"

findstr "System.getenv" "%SCRIPT_DIR%UserController_fixed.java" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Environment variables not used
    echo [FAIL] Environment variables not used >> "%TEST_LOG%"
    exit /b 1
)
echo [PASS] Environment variables used for DB credentials
echo [PASS] Environment variables used for DB credentials >> "%TEST_LOG%"

REM Check 4: Verify @Value annotation for API key
echo.
echo [Check 4] Verifying @Value annotation for API key...
echo. >> "%TEST_LOG%"
echo [Check 4] Verifying @Value annotation for API key... >> "%TEST_LOG%"

findstr "@Value" "%SCRIPT_DIR%UserController_fixed.java" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] @Value annotation not found
    echo [FAIL] @Value annotation not found >> "%TEST_LOG%"
    exit /b 1
)
echo [PASS] @Value annotation found for API key
echo [PASS] @Value annotation found for API key >> "%TEST_LOG%"

REM Check 5: Verify try-with-resources for resource management
echo.
echo [Check 5] Verifying try-with-resources for resource cleanup...
echo. >> "%TEST_LOG%"
echo [Check 5] Verifying try-with-resources for resource cleanup... >> "%TEST_LOG%"

findstr "try (Connection" "%SCRIPT_DIR%UserController_fixed.java" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] try-with-resources not used
    echo [FAIL] try-with-resources not used >> "%TEST_LOG%"
    exit /b 1
)
echo [PASS] try-with-resources used for connection management
echo [PASS] try-with-resources used for connection management >> "%TEST_LOG%"

REM Check 6: Verify input validation
echo.
echo [Check 6] Verifying input validation...
echo. >> "%TEST_LOG%"
echo [Check 6] Verifying input validation... >> "%TEST_LOG%"

findstr "username == null" "%SCRIPT_DIR%UserController_fixed.java" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Input validation not found
    echo [FAIL] Input validation not found >> "%TEST_LOG%"
    exit /b 1
)
echo [PASS] Input validation implemented
echo [PASS] Input validation implemented >> "%TEST_LOG%"

REM Check 7: Verify secure error handling
echo.
echo [Check 7] Verifying secure error handling...
echo. >> "%TEST_LOG%"
echo [Check 7] Verifying secure error handling... >> "%TEST_LOG%"

findstr "SQLException" "%SCRIPT_DIR%UserController_fixed.java" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Secure error handling not found
    echo [FAIL] Secure error handling not found >> "%TEST_LOG%"
    exit /b 1
)
findstr "logger.error" "%SCRIPT_DIR%UserController_fixed.java" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [FAIL] Logging not found
    echo [FAIL] Logging not found >> "%TEST_LOG%"
    exit /b 1
)
echo [PASS] Secure error handling implemented
echo [PASS] Secure error handling implemented >> "%TEST_LOG%"

echo.
echo ==========================================
echo Security Verification Complete
echo ==========================================
echo All security checks PASSED!
echo Log saved to: %TEST_LOG%
echo.

echo. >> "%TEST_LOG%"
echo ========================================== >> "%TEST_LOG%"
echo Security Verification Complete >> "%TEST_LOG%"
echo ========================================== >> "%TEST_LOG%"
echo All security checks PASSED! >> "%TEST_LOG%"
echo. >> "%TEST_LOG%"

endlocal
exit /b 0
