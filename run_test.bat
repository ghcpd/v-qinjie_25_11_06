@echo off
if not exist logs\ mkdir logs
where mvn >nul 2>&1
if errorlevel 1 (
  echo Maven not found, try running in Docker.
  docker build -t secure-user-test .
  docker run --rm secure-user-test mvn test > logs\test_run.log 2>&1
) else (
  mvn test > logs\test_run.log 2>&1
)
:skip
