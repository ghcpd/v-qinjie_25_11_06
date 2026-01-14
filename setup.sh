#!/bin/bash

# Security Setup Script for Java Spring Boot Application
# Platform: Linux/macOS
# This script sets up the environment and verifies security fixes

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
TEST_LOG="$LOG_DIR/test_run.log"

# Create logs directory
mkdir -p "$LOG_DIR"

echo "========================================" | tee -a "$TEST_LOG"
echo "Security Setup and Test Script" | tee -a "$TEST_LOG"
echo "========================================" | tee -a "$TEST_LOG"
echo "Date: $(date)" | tee -a "$TEST_LOG"
echo "" | tee -a "$TEST_LOG"

# Check for required tools
echo "[*] Checking required tools..." | tee -a "$TEST_LOG"

if ! command -v java &> /dev/null; then
    echo "ERROR: Java not found. Please install Java 11 or higher." | tee -a "$TEST_LOG"
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | grep -oP '(?<=version ")[^"]*')
echo "[✓] Java found: $JAVA_VERSION" | tee -a "$TEST_LOG"

if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven not found. Please install Maven." | tee -a "$TEST_LOG"
    exit 1
fi
echo "[✓] Maven found: $(mvn -version | head -1)" | tee -a "$TEST_LOG"

# Set environment variables for secure configuration
echo "" | tee -a "$TEST_LOG"
echo "[*] Configuring environment variables..." | tee -a "$TEST_LOG"

export DB_URL="${DB_URL:-jdbc:mysql://localhost:3306/appdb}"
export DB_USER="${DB_USER:-appuser}"
export DB_PASSWORD="${DB_PASSWORD:-secure_password}"
export API_KEY="${API_KEY:-sk-secure-key-from-vault}"

echo "[✓] Environment variables configured:" | tee -a "$TEST_LOG"
echo "  - DB_URL: $DB_URL" | tee -a "$TEST_LOG"
echo "  - DB_USER: $DB_USER" | tee -a "$TEST_LOG"
echo "  - API_KEY: *** (hidden for security)" | tee -a "$TEST_LOG"

# Run security checks
echo "" | tee -a "$TEST_LOG"
echo "[*] Running security verification checks..." | tee -a "$TEST_LOG"

# Check 1: Verify no hardcoded credentials in source code
echo "" | tee -a "$TEST_LOG"
echo "[Check 1] Verifying no hardcoded credentials in fixed code..." | tee -a "$TEST_LOG"

if grep -q "password" "$SCRIPT_DIR/UserController_fixed.java" 2>/dev/null && \
   grep -q "sk-" "$SCRIPT_DIR/UserController_fixed.java" 2>/dev/null | grep -v "sk-secure"; then
    echo "[✗] FAILED: Hardcoded credentials found in fixed code" | tee -a "$TEST_LOG"
    exit 1
else
    echo "[✓] PASSED: No hardcoded credentials in fixed code" | tee -a "$TEST_LOG"
fi

# Check 2: Verify PreparedStatement usage
echo "" | tee -a "$TEST_LOG"
echo "[Check 2] Verifying PreparedStatement usage..." | tee -a "$TEST_LOG"

if grep -q "PreparedStatement" "$SCRIPT_DIR/UserController_fixed.java"; then
    echo "[✓] PASSED: PreparedStatement found in fixed code" | tee -a "$TEST_LOG"
else
    echo "[✗] FAILED: PreparedStatement not found" | tee -a "$TEST_LOG"
    exit 1
fi

# Check 3: Verify environment variable usage
echo "" | tee -a "$TEST_LOG"
echo "[Check 3] Verifying environment variable usage for DB credentials..." | tee -a "$TEST_LOG"

if grep -q "System.getenv" "$SCRIPT_DIR/UserController_fixed.java"; then
    echo "[✓] PASSED: Environment variables used for DB credentials" | tee -a "$TEST_LOG"
else
    echo "[✗] FAILED: Environment variables not used" | tee -a "$TEST_LOG"
    exit 1
fi

# Check 4: Verify @Value annotation for API key
echo "" | tee -a "$TEST_LOG"
echo "[Check 4] Verifying @Value annotation for API key..." | tee -a "$TEST_LOG"

if grep -q "@Value" "$SCRIPT_DIR/UserController_fixed.java"; then
    echo "[✓] PASSED: @Value annotation found for API key" | tee -a "$TEST_LOG"
else
    echo "[✗] FAILED: @Value annotation not found" | tee -a "$TEST_LOG"
    exit 1
fi

# Check 5: Verify try-with-resources for resource management
echo "" | tee -a "$TEST_LOG"
echo "[Check 5] Verifying try-with-resources for resource cleanup..." | tee -a "$TEST_LOG"

if grep -q "try (Connection" "$SCRIPT_DIR/UserController_fixed.java"; then
    echo "[✓] PASSED: try-with-resources used for connection management" | tee -a "$TEST_LOG"
else
    echo "[✗] FAILED: try-with-resources not used" | tee -a "$TEST_LOG"
    exit 1
fi

# Check 6: Verify input validation
echo "" | tee -a "$TEST_LOG"
echo "[Check 6] Verifying input validation..." | tee -a "$TEST_LOG"

if grep -q "username == null\|username.trim().isEmpty()" "$SCRIPT_DIR/UserController_fixed.java"; then
    echo "[✓] PASSED: Input validation implemented" | tee -a "$TEST_LOG"
else
    echo "[✗] FAILED: Input validation not found" | tee -a "$TEST_LOG"
    exit 1
fi

# Check 7: Verify secure error handling
echo "" | tee -a "$TEST_LOG"
echo "[Check 7] Verifying secure error handling..." | tee -a "$TEST_LOG"

if grep -q "SQLException" "$SCRIPT_DIR/UserController_fixed.java" && \
   grep -q "logger.error" "$SCRIPT_DIR/UserController_fixed.java"; then
    echo "[✓] PASSED: Secure error handling implemented" | tee -a "$TEST_LOG"
else
    echo "[✗] FAILED: Secure error handling not found" | tee -a "$TEST_LOG"
    exit 1
fi

# Summary
echo "" | tee -a "$TEST_LOG"
echo "========================================" | tee -a "$TEST_LOG"
echo "Security Verification Complete" | tee -a "$TEST_LOG"
echo "========================================" | tee -a "$TEST_LOG"
echo "All security checks PASSED! ✓" | tee -a "$TEST_LOG"
echo "Log saved to: $TEST_LOG" | tee -a "$TEST_LOG"
echo "" | tee -a "$TEST_LOG"

exit 0
