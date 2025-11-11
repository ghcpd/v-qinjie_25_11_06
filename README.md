# Security Audit Report - Spring Boot Application

## Overview
This repository contains a security audit of a Spring Boot web application, identifying and fixing critical security vulnerabilities including SQL injection and hardcoded secrets.

## Files

### Source Code
- `input.java` - Original vulnerable code
- `UserController_fixed.java` - Secure version with all vulnerabilities fixed
- `application.properties` - Externalized configuration (secure)

### Reports
- `security_audit_report.json` - Comprehensive security audit report in JSON format

### Build Files
- `pom.xml` - Maven project configuration
- `Dockerfile` - Docker container definition
- `docker-compose.yml` - Docker Compose configuration for full stack

### Test Scripts
- `setup.sh` - Linux/macOS environment setup
- `run_test.sh` - Linux/macOS test runner
- `run_test.bat` - Windows test runner
- `auto_test_runner.sh` - Universal auto-detecting test runner (Linux/macOS)
- `auto_test_runner.bat` - Universal auto-detecting test runner (Windows)

## Detected Vulnerabilities

### 1. SQL Injection (CRITICAL)
- **Location**: `input.java:13`
- **Issue**: Direct string concatenation in SQL query
- **Fix**: Use PreparedStatement with parameterized queries

### 2. Hardcoded API Key (HIGH)
- **Location**: `input.java:7`
- **Issue**: API key hardcoded in source code
- **Fix**: Externalize using @Value annotation with environment variables

### 3. Hardcoded Database Credentials (CRITICAL)
- **Location**: `input.java:11`
- **Issue**: Database password hardcoded in source code
- **Fix**: Use DataSource bean with externalized configuration

## Quick Start

### Linux/macOS
```bash
chmod +x setup.sh run_test.sh auto_test_runner.sh
./setup.sh
./auto_test_runner.sh
```

### Windows
```cmd
run_test.bat
```
or
```cmd
auto_test_runner.bat
```

### Docker
```bash
docker-compose up --build
```

## Environment Variables

Set these environment variables before running:

```bash
export APP_API_KEY=your-secure-api-key-here
export DB_USERNAME=your-db-username
export DB_PASSWORD=your-secure-db-password
```

## Test Results

Test logs are saved to `logs/test_run.log`. Review this file for detailed test execution results.

## Security Best Practices Implemented

1. ✅ Parameterized SQL queries (PreparedStatement)
2. ✅ Externalized configuration (environment variables)
3. ✅ DataSource bean for connection management
4. ✅ Proper exception handling without information disclosure
5. ✅ Resource management with try-with-resources

## Verification Steps

1. Review `security_audit_report.json` for detailed vulnerability information
2. Compare `input.java` with `UserController_fixed.java`
3. Run test scripts to verify fixes
4. Check logs/test_run.log for test results

