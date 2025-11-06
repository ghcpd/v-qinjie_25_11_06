#!/usr/bin/env bash
mkdir -p logs
echo "Starting tests" > logs/test_run.log
if [ -f mvnw ]; then
  ./mvnw -q test >> logs/test_run.log 2>&1
else
  mvn -q test >> logs/test_run.log 2>&1
fi
echo "Tests finished" >> logs/test_run.log
