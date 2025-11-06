#!/bin/bash
# auto_test.sh - Automatic environment detection and test execution

echo "Automatic Security Test Runner"
echo "==============================="

# Create logs directory if it doesn't exist
mkdir -p logs

# Detect environment and run appropriate test
echo "Detecting environment..." > logs/auto_test.log

if [ -f /.dockerenv ]; then
    echo "Docker environment detected" | tee -a logs/auto_test.log
    echo "Running Docker-compatible test script..." | tee -a logs/auto_test.log
    ./run_test.sh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux environment detected" | tee -a logs/auto_test.log
    echo "Running Linux test script..." | tee -a logs/auto_test.log
    ./run_test.sh
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macOS environment detected" | tee -a logs/auto_test.log
    echo "Running macOS test script..." | tee -a logs/auto_test.log
    ./run_test.sh
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "Windows environment detected" | tee -a logs/auto_test.log
    echo "Please use auto_test.bat for Windows" | tee -a logs/auto_test.log
else
    echo "Unknown environment: $OSTYPE" | tee -a logs/auto_test.log
    echo "Attempting to run generic test..." | tee -a logs/auto_test.log
    ./run_test.sh
fi

echo ""
echo "Auto test execution completed."
echo "Check logs/auto_test.log and logs/test_run.log for details."