#!/bin/bash

# Universal Test Runner - Auto-detects environment and runs appropriate tests
# Works on Linux, macOS, and Windows (via Git Bash/WSL)

set -e

# Create logs directory
mkdir -p logs

LOG_FILE="logs/test_run.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "==========================================" | tee -a "$LOG_FILE"
echo "Automatic Security Test Runner" | tee -a "$LOG_FILE"
echo "Started: $TIMESTAMP" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Detect operating system
OS_TYPE=$(uname -s)
echo "Detected OS: $OS_TYPE" | tee -a "$LOG_FILE"

# Detect if running in Docker
if [ -f /.dockerenv ] || grep -qa docker /proc/1/cgroup 2>/dev/null; then
    ENV_TYPE="Docker"
    echo "Environment: Docker Container" | tee -a "$LOG_FILE"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    ENV_TYPE="Linux"
    echo "Environment: Linux" | tee -a "$LOG_FILE"
    # Run Linux test script
    if [ -f "run_test.sh" ]; then
        chmod +x run_test.sh
        ./run_test.sh
    else
        echo "Error: run_test.sh not found" | tee -a "$LOG_FILE"
        exit 1
    fi
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    ENV_TYPE="macOS"
    echo "Environment: macOS" | tee -a "$LOG_FILE"
    # Run Linux test script (same for macOS)
    if [ -f "run_test.sh" ]; then
        chmod +x run_test.sh
        ./run_test.sh
    else
        echo "Error: run_test.sh not found" | tee -a "$LOG_FILE"
        exit 1
    fi
elif [[ "$OS_TYPE" == *"MINGW"* ]] || [[ "$OS_TYPE" == *"MSYS"* ]] || [[ "$OS_TYPE" == *"CYGWIN"* ]]; then
    ENV_TYPE="Windows"
    echo "Environment: Windows (Git Bash/WSL)" | tee -a "$LOG_FILE"
    # Try to run Windows batch file via cmd
    if [ -f "run_test.bat" ]; then
        cmd.exe //c run_test.bat
    else
        echo "Error: run_test.bat not found" | tee -a "$LOG_FILE"
        exit 1
    fi
else
    ENV_TYPE="Unknown"
    echo "Warning: Unknown OS type: $OS_TYPE" | tee -a "$LOG_FILE"
    echo "Attempting to run Linux test script..." | tee -a "$LOG_FILE"
    if [ -f "run_test.sh" ]; then
        chmod +x run_test.sh
        ./run_test.sh
    else
        echo "Error: No suitable test script found" | tee -a "$LOG_FILE"
        exit 1
    fi
fi

echo "" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo "Test execution completed" | tee -a "$LOG_FILE"
echo "Log saved to: $LOG_FILE" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"

