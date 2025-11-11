#!/bin/bash

# Security Audit Setup Script for Linux/macOS
# This script sets up the environment for testing the secure Spring Boot application

set -e

echo "=========================================="
echo "Security Audit Environment Setup"
echo "=========================================="

# Create logs directory
mkdir -p logs
echo "✓ Created logs directory"

# Check Java installation
if ! command -v java &> /dev/null; then
    echo "✗ Java is not installed. Please install Java JDK 17 or higher."
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | head -n 1)
echo "✓ Java found: $JAVA_VERSION"

# Check Maven installation
if ! command -v mvn &> /dev/null; then
    echo "✗ Maven is not installed. Installing Maven..."
    # You may need to adjust this based on your system
    echo "Please install Maven manually: https://maven.apache.org/install.html"
    exit 1
fi
MAVEN_VERSION=$(mvn -version | head -n 1)
echo "✓ Maven found: $MAVEN_VERSION"

# Check MySQL installation (optional for full testing)
if command -v mysql &> /dev/null; then
    MYSQL_VERSION=$(mysql --version)
    echo "✓ MySQL found: $MYSQL_VERSION"
else
    echo "⚠ MySQL not found. Database tests will be skipped."
    echo "  Install MySQL or use Docker Compose for database testing."
fi

# Check Docker installation (optional)
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo "✓ Docker found: $DOCKER_VERSION"
else
    echo "⚠ Docker not found. Docker-based testing will be skipped."
fi

# Set environment variables
export APP_API_KEY="${APP_API_KEY:-sk-test-key-change-in-production}"
export DB_USERNAME="${DB_USERNAME:-root}"
export DB_PASSWORD="${DB_PASSWORD:-password}"

echo ""
echo "Environment variables set:"
echo "  APP_API_KEY: ${APP_API_KEY:0:10}..."
echo "  DB_USERNAME: $DB_USERNAME"
echo "  DB_PASSWORD: [HIDDEN]"

echo ""
echo "=========================================="
echo "Setup completed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review security_audit_report.json for detected vulnerabilities"
echo "2. Compare input.java with UserController_fixed.java"
echo "3. Run tests: ./run_test.sh"
echo ""

