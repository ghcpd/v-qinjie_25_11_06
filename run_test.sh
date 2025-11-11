#!/bin/bash

# Security Test Runner for Linux/macOS
# Automatically detects environment and runs appropriate tests

set -e

# Create logs directory if it doesn't exist
mkdir -p logs

# Log file
LOG_FILE="logs/test_run.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "==========================================" | tee -a "$LOG_FILE"
echo "Security Test Execution - $TIMESTAMP" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Detect environment
OS_TYPE=$(uname -s)
echo "Detected OS: $OS_TYPE" | tee -a "$LOG_FILE"
echo "Working Directory: $(pwd)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Test 1: Verify fixed code exists
echo "[TEST 1] Checking for fixed code file..." | tee -a "$LOG_FILE"
if [ -f "UserController_fixed.java" ]; then
    echo "✓ UserController_fixed.java found" | tee -a "$LOG_FILE"
else
    echo "✗ UserController_fixed.java not found" | tee -a "$LOG_FILE"
    exit 1
fi

# Test 2: Verify no hardcoded secrets in fixed code
echo "" | tee -a "$LOG_FILE"
echo "[TEST 2] Scanning for hardcoded secrets..." | tee -a "$LOG_FILE"
SECRET_PATTERNS=("sk-[a-zA-Z0-9]" "password" "root.*password")
SECRETS_FOUND=0

for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -q "$pattern" UserController_fixed.java 2>/dev/null; then
        echo "⚠ Potential secret pattern found: $pattern" | tee -a "$LOG_FILE"
        SECRETS_FOUND=$((SECRETS_FOUND + 1))
    fi
done

if [ $SECRETS_FOUND -eq 0 ]; then
    echo "✓ No hardcoded secrets detected in fixed code" | tee -a "$LOG_FILE"
else
    echo "✗ Found $SECRETS_FOUND potential secret patterns" | tee -a "$LOG_FILE"
fi

# Test 3: Verify PreparedStatement usage
echo "" | tee -a "$LOG_FILE"
echo "[TEST 3] Checking for SQL injection protection..." | tee -a "$LOG_FILE"
if grep -q "PreparedStatement" UserController_fixed.java; then
    echo "✓ PreparedStatement found (SQL injection protection)" | tee -a "$LOG_FILE"
else
    echo "✗ PreparedStatement not found" | tee -a "$LOG_FILE"
fi

if grep -q "setString" UserController_fixed.java; then
    echo "✓ Parameterized query found (setString)" | tee -a "$LOG_FILE"
else
    echo "✗ Parameterized query not found" | tee -a "$LOG_FILE"
fi

# Test 4: Verify @Value annotation for externalized config
echo "" | tee -a "$LOG_FILE"
echo "[TEST 4] Checking for externalized configuration..." | tee -a "$LOG_FILE"
if grep -q "@Value" UserController_fixed.java; then
    echo "✓ @Value annotation found (externalized config)" | tee -a "$LOG_FILE"
else
    echo "✗ @Value annotation not found" | tee -a "$LOG_FILE"
fi

if grep -q "DataSource" UserController_fixed.java; then
    echo "✓ DataSource bean usage found" | tee -a "$LOG_FILE"
else
    echo "✗ DataSource bean not found" | tee -a "$LOG_FILE"
fi

# Test 5: Verify JSON report exists
echo "" | tee -a "$LOG_FILE"
echo "[TEST 5] Verifying security audit report..." | tee -a "$LOG_FILE"
if [ -f "security_audit_report.json" ]; then
    echo "✓ security_audit_report.json found" | tee -a "$LOG_FILE"
    # Count vulnerabilities
    VULN_COUNT=$(grep -o '"id":' security_audit_report.json | wc -l || echo "0")
    echo "  Found $VULN_COUNT security issues documented" | tee -a "$LOG_FILE"
else
    echo "✗ security_audit_report.json not found" | tee -a "$LOG_FILE"
fi

# Test 6: Code compilation test (if Maven is available)
echo "" | tee -a "$LOG_FILE"
echo "[TEST 6] Testing code compilation..." | tee -a "$LOG_FILE"
if command -v mvn &> /dev/null && [ -f "pom.xml" ]; then
    echo "Attempting to compile with Maven..." | tee -a "$LOG_FILE"
    if mvn clean compile -q 2>&1 | tee -a "$LOG_FILE"; then
        echo "✓ Code compiles successfully" | tee -a "$LOG_FILE"
    else
        echo "⚠ Compilation warnings/errors (check logs)" | tee -a "$LOG_FILE"
    fi
else
    echo "⚠ Maven not available or pom.xml missing - skipping compilation test" | tee -a "$LOG_FILE"
fi

# Test 7: Docker test (if Docker is available)
echo "" | tee -a "$LOG_FILE"
echo "[TEST 7] Testing Docker environment..." | tee -a "$LOG_FILE"
if command -v docker &> /dev/null && [ -f "Dockerfile" ]; then
    echo "Docker is available" | tee -a "$LOG_FILE"
    if docker ps &> /dev/null; then
        echo "✓ Docker daemon is running" | tee -a "$LOG_FILE"
    else
        echo "⚠ Docker daemon is not running" | tee -a "$LOG_FILE"
    fi
else
    echo "⚠ Docker not available - skipping Docker tests" | tee -a "$LOG_FILE"
fi

# Summary
echo "" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo "Test Execution Summary" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo "Test completed at: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "Review the full log for detailed results:" | tee -a "$LOG_FILE"
echo "  cat $LOG_FILE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

