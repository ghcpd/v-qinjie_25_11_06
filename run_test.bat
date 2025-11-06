@echo off
setlocal enabledelayedexpansion
md logs 2>nul
set LOGFILE=logs\test_run.log

REM Log start info
echo ===== Test Run Started: %DATE% %TIME% ===== > %LOGFILE%
echo Platform: %OS% >> %LOGFILE%

REM Detect Docker
where docker >nul 2>&1
if errorlevel 1 (
  echo Docker not found. Running via Maven. >>%LOGFILE%
  REM Ensure mvn exists
  where mvn >nul 2>&1
  if errorlevel 1 (
    echo ERROR: Maven not found in PATH. Cannot build application. >>%LOGFILE%
    exit /b 1
  )
  REM Build the project first to ensure target JAR exists
  
  echo Building project via Maven... >>%LOGFILE%
  mvn -q -DskipTests package >>%LOGFILE% 2>&1
  if errorlevel 1 (
    echo ERROR: Maven build failed. >>%LOGFILE%
    exit /b 1
  )
  REM Start the application in background and capture PID
  set APP_API_KEY=testkey
  echo Starting Spring Boot via java -jar target/demo-1.0.0.jar >>%LOGFILE%
  start "secure-demo" /B cmd /C "java -jar target\demo-1.0.0.jar >>%LOGFILE% 2>&1"
  REM Give the app time to start with retries
  set /a retries=0
  :waitloop
  powershell -Command "try{(Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:8080/getUser?username=admin' -TimeoutSec 2).Content}catch{Write-Host ''}" >nul 2>&1
  if %errorlevel%==0 (
    goto started
  )
  timeout /T 2 /NOBREAK >nul
  set /a retries+=1
  if !retries! LSS 20 goto waitloop
  echo ERROR: Server did not start within expected time >>%LOGFILE%
  exit /b 1
  :started
) else (
  echo Docker detected. Building and running the app in Docker... >>%LOGFILE%
  docker build -t secure-demo . >>%LOGFILE% 2>&1
  if errorlevel 1 (
    echo ERROR: Docker build failed >>%LOGFILE%
    exit /b 1
  )
  docker run -d -p 8080:8080 --name secure-demo-test secure-demo >>%LOGFILE% 2>&1
  timeout /T 8 /NOBREAK >nul
)

REM Run tests
echo Running verification tests... >>%LOGFILE%

REM Function: try to get content using curl or PowerShell
set GOOD=
set INJECT=
where curl >nul 2>&1
if errorlevel 1 (
  for /f "delims=" %%a in ('powershell -Command "(Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:8080/getUser?username=admin').Content"') do set GOOD=%%a
  for /f "delims=" %%a in ('powershell -Command "(Invoke-WebRequest -UseBasicParsing -Uri 'http://localhost:8080/getUser?username=admin%27%20OR%20%271%27%3D%271').Content"') do set INJECT=%%a
) else (
  for /f "delims=" %%a in ('curl -s "http://localhost:8080/getUser?username=admin"') do set GOOD=%%a
  for /f "delims=" %%a in ('curl -s "http://localhost:8080/getUser?username=admin%27%20OR%20%271%27%3D%271"') do set INJECT=%%a
)

echo Response for valid user: %GOOD% >>%LOGFILE%
echo Response for injection attempt: %INJECT% >>%LOGFILE%

REM Evaluate results
if "%GOOD%"=="Welcome, admin" (
  echo "Valid user response is correct" >>%LOGFILE%
  if not "%INJECT:Welcome=%"=="%INJECT%" (
    echo TEST FAILED: Injection succeeded >>%LOGFILE%
    set EXIT_CODE=2
  ) else (
    echo TEST PASSED: Prepared statements prevent SQL injection. >>%LOGFILE%
    set EXIT_CODE=0
  )
) else (
  echo TEST FAILED: Could not find expected user or server not started >>%LOGFILE%
  set EXIT_CODE=2
)

REM Teardown
echo Tearing down... >>%LOGFILE%
where docker >nul 2>&1
if errorlevel 1 (
  REM Kill java process started by this script (best effort)
  tasklist /FI "IMAGENAME eq java.exe" /NH | findstr /R /C:"java.exe" >nul 2>&1
  if %ERRORLEVEL%==0 (
    for /f "tokens=2" %%p in ('tasklist /FI "IMAGENAME eq java.exe" /FO CSV /NH') do taskkill /PID %%~p /F >>%LOGFILE% 2>&1
  )
) else (
  docker rm -f secure-demo-test >>%LOGFILE% 2>&1
)

echo ===== Test Run Completed: %DATE% %TIME% ===== >> %LOGFILE%
exit /b %EXIT_CODE%
