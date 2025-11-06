#!/usr/bin/env bash
# detect environment
mkdir -p logs
if [ -n "$CI" ]; then
  echo "CI environment detected"
fi

if command -v mvn >/dev/null 2>&1; then
  echo "Running tests with Maven"
  mvn -q test | tee logs/test_run.log
elif [ -f Dockerfile ]; then
  echo "Maven not found but Dockerfile present; using Docker to run tests"
  docker build -t secure-user-test .
  docker run --rm secure-user-test mvn -q test | tee logs/test_run.log
else
  echo "Maven not found. Install maven or run in Docker. Exiting." | tee logs/test_run.log
  exit 1
fi
