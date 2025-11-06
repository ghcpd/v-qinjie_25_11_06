#!/usr/bin/env bash
set -e
mkdir -p logs
LOGFILE=logs/test_run.log

# Detect environment: Docker vs Host
if command -v docker >/dev/null 2>&1; then
  echo "Docker detected. Building and running the app in Docker..." | tee "$LOGFILE"
  docker build -t secure-demo . 2>&1 | tee -a "$LOGFILE"
  docker run -d -p 8080:8080 --name secure-demo-test secure-demo 2>&1 | tee -a "$LOGFILE"
  # Wait for the app to start
  sleep 8
else
  echo "Docker not found. Running via Maven." | tee "$LOGFILE"
  export APP_API_KEY=testkey
  mvn -q -Dspring-boot.run.fork=false spring-boot:run > "$LOGFILE" 2>&1 &
  APP_PID=$!
  # Give the server time to start (wait for endpoint)
  retries=0
  until curl -fsS "http://localhost:8080/getUser?username=admin" >/dev/null 2>&1 || [ $retries -ge 20 ]; do
    sleep 1
    retries=$((retries + 1))
  done
fi

# Run tests
echo "Running verification tests..." | tee -a "$LOGFILE"

GOOD=$(curl -s "http://localhost:8080/getUser?username=admin")
INJECT=$(curl -s "http://localhost:8080/getUser?username=admin%27%20OR%20%271%27%3D%271")

echo "Response for valid user: $GOOD" | tee -a "$LOGFILE"
echo "Response for injection attempt: $INJECT" | tee -a "$LOGFILE"

# Evaluate results
if [[ "$GOOD" == *"Welcome, admin"* && "$INJECT" != *"Welcome"* ]]; then
  echo "TEST PASSED: Prepared statements prevent SQL injection." | tee -a "$LOGFILE"
  EXIT_CODE=0
else
  echo "TEST FAILED: SQL injection may be possible or test environment misconfigured." | tee -a "$LOGFILE"
  EXIT_CODE=2
fi

# Teardown
if command -v docker >/dev/null 2>&1; then
  docker rm -f secure-demo-test | tee -a "$LOGFILE"
else
  kill $APP_PID || true
fi

exit $EXIT_CODE
