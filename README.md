# Quick Start Guide - Secure Java Spring Boot Application

## Overview

This guide walks you through deploying the secured version of the Spring Boot application with all security vulnerabilities fixed.

---

## System Requirements

- **Java:** 11 or higher
- **Maven:** 3.6.0 or higher
- **MySQL:** 5.7 or higher
- **Memory:** 512MB minimum
- **Disk:** 1GB minimum

---

## Quick Start - Windows

### Step 1: Prepare Environment

```powershell
# Open PowerShell as Administrator

# Navigate to project directory
cd C:\GenAI\Bug_Bash\v-qinjie_25_11_06

# Verify Java installation
java -version

# Verify Maven installation
mvn -version
```

### Step 2: Set Environment Variables

```powershell
# Set for current session (temporary)
$env:DB_URL = "jdbc:mysql://localhost:3306/appdb"
$env:DB_USER = "appuser"
$env:DB_PASSWORD = "your_secure_password"
$env:API_KEY = "sk-your-api-key"

# Verify variables are set
Write-Host "DB_URL: $env:DB_URL"
Write-Host "DB_USER: $env:DB_USER"
Write-Host "API_KEY is set: $($env:API_KEY -ne $null)"
```

**For Permanent Setup (System Environment Variables):**
1. Press `Win + X` and select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Click "New" under "System variables"
5. Add:
   - Variable: `DB_URL` → Value: `jdbc:mysql://localhost:3306/appdb`
   - Variable: `DB_USER` → Value: `appuser`
   - Variable: `DB_PASSWORD` → Value: `your_secure_password`
   - Variable: `API_KEY` → Value: `sk-your-api-key`
6. Click OK and restart applications

### Step 3: Run Security Tests

```powershell
# Execute test script
.\run_test.bat

# View results
Get-Content .\logs\test_run.log
```

### Step 4: Verify All Tests Passed

```
✓ [PASS] No hardcoded credentials in fixed code
✓ [PASS] PreparedStatement found in fixed code
✓ [PASS] Environment variables used for DB credentials
✓ [PASS] @Value annotation found for API key
✓ [PASS] try-with-resources used for connection management
✓ [PASS] Input validation implemented
✓ [PASS] Secure error handling implemented
```

---

## Quick Start - Linux/macOS

### Step 1: Prepare Environment

```bash
# Navigate to project directory
cd /path/to/v-qinjie_25_11_06

# Verify Java installation
java -version

# Verify Maven installation
mvn -version

# Make scripts executable
chmod +x setup.sh run_test.sh
```

### Step 2: Set Environment Variables

```bash
# Set for current session (temporary)
export DB_URL="jdbc:mysql://localhost:3306/appdb"
export DB_USER="appuser"
export DB_PASSWORD="your_secure_password"
export API_KEY="sk-your-api-key"

# Verify variables are set
echo "DB_URL: $DB_URL"
echo "DB_USER: $DB_USER"
echo "API_KEY is set: $([ -z $API_KEY ] && echo 'NO' || echo 'YES')"
```

**For Permanent Setup (add to ~/.bashrc or ~/.zshrc):**

```bash
cat >> ~/.bashrc << 'EOF'
# Application Environment Variables
export DB_URL="jdbc:mysql://localhost:3306/appdb"
export DB_USER="appuser"
export DB_PASSWORD="your_secure_password"
export API_KEY="sk-your-api-key"
EOF

source ~/.bashrc
```

### Step 3: Run Security Tests

```bash
# Execute setup and tests
bash setup.sh

# Run automated tests
bash run_test.sh

# View results
cat logs/test_run.log
```

### Step 4: Verify All Tests Passed

```
✓ [PASS] No hardcoded credentials in fixed code
✓ [PASS] PreparedStatement found in fixed code
✓ [PASS] Environment variables used for DB credentials
✓ [PASS] @Value annotation found for API key
✓ [PASS] try-with-resources used for connection management
✓ [PASS] Input validation implemented
✓ [PASS] Secure error handling implemented
```

---

## Docker Deployment

### Build Docker Image

```bash
docker build -t secure-user-app:1.0 .
```

### Run Container with Environment Variables

```bash
docker run -d \
  --name user-app \
  -p 8080:8080 \
  -e DB_URL="jdbc:mysql://mysql-host:3306/appdb" \
  -e DB_USER="appuser" \
  -e DB_PASSWORD="secure_password" \
  -e API_KEY="sk-secure-api-key" \
  secure-user-app:1.0
```

### Using Docker Compose

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  app:
    image: secure-user-app:1.0
    ports:
      - "8080:8080"
    environment:
      DB_URL: jdbc:mysql://mysql:3306/appdb
      DB_USER: appuser
      DB_PASSWORD: ${DB_PASSWORD}
      API_KEY: ${API_KEY}
    depends_on:
      - mysql

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: appdb
      MYSQL_USER: appuser
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

Run with:
```bash
export DB_PASSWORD="your_password"
export MYSQL_ROOT_PASSWORD="root_password"
export API_KEY="sk-your-api-key"
docker-compose up
```

---

## Testing the Application

### Test 1: Valid User Query

```bash
curl -X GET "http://localhost:8080/api/getUser?username=john"
```

Expected Response: `Welcome, john` (if user exists in database)

### Test 2: SQL Injection Attempt (NOW SAFE)

```bash
# Old vulnerability: Would return all users
curl -X GET "http://localhost:8080/api/getUser?username=' OR '1'='1 --"
```

Expected Response: `User not found.` (SQL injection prevented!)

### Test 3: Invalid Input

```bash
curl -X GET "http://localhost:8080/api/getUser?username="
```

Expected Response: `Invalid username.`

### Test 4: Special Characters (Now Safe)

```bash
curl -X GET "http://localhost:8080/api/getUser?username=test%27s"
```

Expected Response: Searches for user named `test's` (no injection)

---

## File Structure

```
v-qinjie_25_11_06/
├── input.java                          # Original vulnerable code
├── UserController_fixed.java           # ✓ Secured version
├── security_audit_report.json          # ✓ Detailed vulnerability report
├── SECURITY_AUDIT.md                   # ✓ Full audit documentation
├── Dockerfile                          # ✓ Container configuration
├── requirements.txt                    # ✓ Dependencies
├── application.properties.example      # ✓ Configuration template
├── .gitignore                          # ✓ Git security rules
├── setup.sh                            # ✓ Linux/macOS setup
├── run_test.sh                         # ✓ Linux/macOS tests
├── run_test.bat                        # ✓ Windows tests
├── README.md                           # ✓ This file
└── logs/
    └── test_run.log                    # ✓ Test execution results
```

---

## Verification Checklist

- [ ] Java 11+ installed: `java -version`
- [ ] Maven installed: `mvn -version`
- [ ] All environment variables set (DB_URL, DB_USER, DB_PASSWORD, API_KEY)
- [ ] Test script executed successfully
- [ ] All 7 security checks PASSED
- [ ] No hardcoded credentials in `UserController_fixed.java`
- [ ] Application deployed with environment variables
- [ ] Log file contains: "All security checks PASSED"
- [ ] SQL injection test returns "User not found"
- [ ] Valid user queries work correctly

---

## Key Security Changes

| Issue | Before | After |
|-------|--------|-------|
| SQL Injection | `"SELECT * FROM users WHERE username = '" + username + "'"` | `PreparedStatement with parameterized query` |
| API Key | `private static final String API_KEY = "sk-1234567890abcdef"` | `@Value("${api.key}")` from environment |
| DB Credentials | Hardcoded in connection string | `System.getenv()` from environment variables |
| Resource Management | Manual close (or none) | `try-with-resources` automatic cleanup |
| Error Handling | `throws Exception` | Specific `SQLException` with secure logging |
| Input Validation | None | Null and empty checks |

---

## Troubleshooting

### Issue: "PreparedStatement not found"

**Solution:** Ensure you're using `UserController_fixed.java`, not the original `input.java`

```bash
# Verify the file contains PreparedStatement
grep -n "PreparedStatement" UserController_fixed.java
```

### Issue: Database connection fails

**Solution:** Check environment variables are set

```powershell
# Windows
echo $env:DB_URL
echo $env:DB_USER

# Linux/macOS
echo $DB_URL
echo $DB_USER
```

### Issue: Test script fails

**Solution:** Check file permissions and Java installation

```bash
# Make scripts executable (Linux/macOS)
chmod +x setup.sh run_test.sh

# Verify Java
java -version

# Run with verbose output
bash -x run_test.sh
```

---

## Additional Resources

- **Security Audit Report:** `security_audit_report.json`
- **Detailed Documentation:** `SECURITY_AUDIT.md`
- **Test Results:** `logs/test_run.log`
- **Configuration Template:** `application.properties.example`

---

## Support

For detailed information about each vulnerability and fix, see:
- Individual vulnerability sections in `SECURITY_AUDIT.md`
- Structured data in `security_audit_report.json`
- Source code comments in `UserController_fixed.java`

---

**Status:** ✓ All vulnerabilities fixed and verified  
**Last Updated:** November 6, 2025  
**Test Results:** ✓ ALL TESTS PASSED

