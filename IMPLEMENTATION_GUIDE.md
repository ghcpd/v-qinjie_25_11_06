# Implementation Guide - Security Fixes for Spring Boot Application

## Table of Contents
1. [Overview](#overview)
2. [SQL Injection Fix](#sql-injection-fix)
3. [Secrets Management](#secrets-management)
4. [Resource Management](#resource-management)
5. [Error Handling](#error-handling)
6. [Testing & Verification](#testing--verification)
7. [Deployment](#deployment)

---

## Overview

### Vulnerabilities Addressed

| ID | Vulnerability | Severity | Status |
|----|---|---|---|
| SQLI-001 | SQL Injection in query | CRITICAL | ✓ FIXED |
| SECRET-001 | Hardcoded API Key | CRITICAL | ✓ FIXED |
| SECRET-002 | Hardcoded DB Credentials | CRITICAL | ✓ FIXED |
| ISSUE-003 | Resource Leak | HIGH | ✓ FIXED |
| ISSUE-004 | Generic Exception Handling | MEDIUM | ✓ FIXED |
| ISSUE-005 | Missing Input Validation | MEDIUM | ✓ FIXED |

---

## SQL Injection Fix

### Problem: String Concatenation in SQL

**Vulnerable Code:**
```java
@GetMapping("/getUser")
public String getUser(@RequestParam String username) throws Exception {
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/appdb", "root", "password");
    Statement stmt = conn.createStatement();
    String query = "SELECT * FROM users WHERE username = '" + username + "'";  // ❌ VULNERABLE
    ResultSet rs = stmt.executeQuery(query);
    // ...
}
```

**Attack Vector:**
```
GET /getUser?username=' OR '1'='1 --
→ Query becomes: SELECT * FROM users WHERE username = '' OR '1'='1 --'
→ Returns ALL users
```

### Solution: PreparedStatement with Parameterized Queries

**Fixed Code:**
```java
@GetMapping("/getUser")
public String getUser(@RequestParam String username) {
    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
        // ✓ Parameterized query separates SQL code from data
        String query = "SELECT * FROM users WHERE username = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            // ✓ User input is treated as literal data, not executable code
            pstmt.setString(1, username);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return "Welcome, " + rs.getString("username");
                }
            }
        }
    } catch (SQLException e) {
        logger.error("Database error", e);
        return "An error occurred.";
    }
}
```

### Why PreparedStatement Works

1. **Separation of Concerns**
   - SQL structure defined in the query string
   - Data provided separately via `setString()`, `setInt()`, etc.
   - Database driver handles proper escaping

2. **Automatic Escaping**
   - The database driver escapes special characters automatically
   - Quote characters are escaped as needed
   - Works for any database (MySQL, PostgreSQL, Oracle, etc.)

3. **Type Safety**
   - `setString()` - treats parameter as string
   - `setInt()` - treats parameter as integer
   - Cannot inject SQL syntax through type coercion

### Testing SQL Injection Prevention

```java
// Test 1: Normal query
String username = "john";
// Query: SELECT * FROM users WHERE username = 'john'
// Result: Returns user john if exists

// Test 2: SQL injection attempt (now safe)
String username = "' OR '1'='1 --";
// Query: SELECT * FROM users WHERE username = '\' OR \'1\'=\'1 --'
// Result: No matches (escaped quotes prevent injection)

// Test 3: More complex injection (still safe)
String username = "'; DROP TABLE users; --";
// Query: SELECT * FROM users WHERE username = '\'; DROP TABLE users; --'
// Result: No matches (entire injection escaped as data)
```

### Other Query Types

All SQL operations should use PreparedStatement:

```java
// INSERT
String insertQuery = "INSERT INTO users (username, email) VALUES (?, ?)";
try (PreparedStatement pstmt = conn.prepareStatement(insertQuery)) {
    pstmt.setString(1, username);
    pstmt.setString(2, email);
    pstmt.executeUpdate();
}

// UPDATE
String updateQuery = "UPDATE users SET email = ? WHERE username = ?";
try (PreparedStatement pstmt = conn.prepareStatement(updateQuery)) {
    pstmt.setString(1, newEmail);
    pstmt.setString(2, username);
    pstmt.executeUpdate();
}

// DELETE
String deleteQuery = "DELETE FROM users WHERE username = ?";
try (PreparedStatement pstmt = conn.prepareStatement(deleteQuery)) {
    pstmt.setString(1, username);
    pstmt.executeUpdate();
}
```

---

## Secrets Management

### Problem: Hardcoded Credentials

**Vulnerable Code:**
```java
public class UserController {
    private static final String API_KEY = "sk-1234567890abcdef";  // ❌ EXPOSED
    
    @GetMapping("/getUser")
    public String getUser(@RequestParam String username) throws Exception {
        // ❌ Credentials hardcoded in connection
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/appdb",
            "root",
            "password"
        );
        // ...
    }
}
```

**Exposure Vectors:**
1. Source code repositories (Git history, backups)
2. Compiled JAR/WAR files
3. Decompiled bytecode
4. Docker images
5. Developer machines
6. Backup systems

### Solution: Environment Variables

**Fixed Code:**
```java
@RestController
public class UserController {
    @Value("${api.key:#{null}}")
    private String apiKey;
    
    @GetMapping("/getUser")
    public String getUser(@RequestParam String username) {
        try {
            // ✓ Load from environment variables
            String dbUrl = System.getenv("DB_URL") != null ? 
                System.getenv("DB_URL") : "jdbc:mysql://localhost:3306/appdb";
            String dbUser = System.getenv("DB_USER");
            String dbPassword = System.getenv("DB_PASSWORD");
            
            // ✓ Validate credentials are provided
            if (dbUser == null || dbPassword == null) {
                logger.error("Database credentials not configured");
                return "System configuration error.";
            }
            
            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
                // Rest of implementation...
            }
        } catch (SQLException e) {
            logger.error("Database error", e);
            return "An error occurred.";
        }
    }
}
```

### Setting Environment Variables

**Windows (Temporary - Current Session):**
```powershell
$env:DB_URL = "jdbc:mysql://localhost:3306/appdb"
$env:DB_USER = "appuser"
$env:DB_PASSWORD = "secure_password_here"
$env:API_KEY = "sk-your-api-key"
```

**Windows (Permanent - System):**
```powershell
# Run as Administrator
[Environment]::SetEnvironmentVariable("DB_URL", "jdbc:mysql://localhost:3306/appdb", "User")
[Environment]::SetEnvironmentVariable("DB_USER", "appuser", "User")
[Environment]::SetEnvironmentVariable("DB_PASSWORD", "secure_password_here", "User")
[Environment]::SetEnvironmentVariable("API_KEY", "sk-your-api-key", "User")
```

**Linux/macOS:**
```bash
# Temporary (current session)
export DB_URL="jdbc:mysql://localhost:3306/appdb"
export DB_USER="appuser"
export DB_PASSWORD="secure_password_here"
export API_KEY="sk-your-api-key"

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export DB_URL="jdbc:mysql://localhost:3306/appdb"' >> ~/.bashrc
echo 'export DB_USER="appuser"' >> ~/.bashrc
echo 'export DB_PASSWORD="secure_password_here"' >> ~/.bashrc
echo 'export API_KEY="sk-your-api-key"' >> ~/.bashrc
source ~/.bashrc
```

**Docker:**
```bash
docker run -e DB_URL="..." -e DB_USER="..." -e DB_PASSWORD="..." -e API_KEY="..." myapp
```

**Kubernetes:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  DB_URL: amRiYzpteXNxbDovL2xvY2FsaG9zdDozMzA2L2FwcGRi  # base64 encoded
  DB_USER: YXBwdXNlcg==
  DB_PASSWORD: c2VjdXJlX3Bhc3N3b3JkX2hlcmU=
  API_KEY: c2steW91ci1hcGkta2V5

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:1.0
        env:
        - name: DB_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DB_URL
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DB_USER
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DB_PASSWORD
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: API_KEY
```

### Using Spring Properties

**application.properties:**
```properties
api.key=${API_KEY}
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USER}
spring.datasource.password=${DB_PASSWORD}
```

**application.yml:**
```yaml
api:
  key: ${API_KEY}
spring:
  datasource:
    url: ${DB_URL}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
```

**Controller Usage:**
```java
@RestController
public class UserController {
    @Value("${api.key}")
    private String apiKey;
    
    @Value("${spring.datasource.url}")
    private String dbUrl;
    
    @Value("${spring.datasource.username}")
    private String dbUser;
    
    @Value("${spring.datasource.password}")
    private String dbPassword;
}
```

### Never Commit Secrets

**.gitignore:**
```
# Never commit these files
application.properties
application.yml
.env
.env.local
secrets/
credentials/
*.key
*.pem
*.p12
```

---

## Resource Management

### Problem: Unclosed Resources

**Vulnerable Code:**
```java
Connection conn = DriverManager.getConnection(...);  // Resource not managed
Statement stmt = conn.createStatement();              // Resource not managed
ResultSet rs = stmt.executeQuery(query);             // Resource not managed

// If exception occurs, resources leak!
if (rs.next()) {
    return rs.getString("username");
}
// Resources never explicitly closed
```

**Impact:**
- Connection pool exhaustion
- Database server runs out of available connections
- Application becomes unresponsive
- Memory leaks in long-running applications
- System resources depleted

### Solution: Try-With-Resources

**Fixed Code:**
```java
// ✓ Automatically closes all resources in reverse order
try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
    String query = "SELECT * FROM users WHERE username = ?";
    try (PreparedStatement pstmt = conn.prepareStatement(query)) {
        pstmt.setString(1, username);
        
        try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return "Welcome, " + rs.getString("username");
            }
        }
    }
} catch (SQLException e) {
    logger.error("Database error", e);
    return "An error occurred.";
}
```

**How Try-With-Resources Works:**
1. Resource declared in parentheses
2. Resource automatically closed when block exits (normal or exception)
3. Multiple resources closed in reverse order
4. Suppressed exceptions properly handled
5. Cleaner code, no finally blocks needed

**Resource Closing Order:**
```
try (
    Resource1 r1 = new Resource1();
    Resource2 r2 = new Resource2();
    Resource3 r3 = new Resource3()
)

// Closed in reverse order:
// r3.close();
// r2.close();
// r1.close();
```

### For Older Java Versions

**If stuck with Java < 7:**
```java
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
    String query = "SELECT * FROM users WHERE username = ?";
    pstmt = conn.prepareStatement(query);
    pstmt.setString(1, username);
    rs = pstmt.executeQuery();
    
    if (rs.next()) {
        return "Welcome, " + rs.getString("username");
    }
} finally {
    // Explicitly close in reverse order
    if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
    if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
    if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
}
```

---

## Error Handling

### Problem: Generic Exception Handling

**Vulnerable Code:**
```java
@GetMapping("/getUser")
public String getUser(@RequestParam String username) throws Exception {  // ❌ Too generic
    Connection conn = DriverManager.getConnection(...);
    Statement stmt = conn.createStatement();
    String query = "SELECT * FROM users WHERE username = '" + username + "'";
    ResultSet rs = stmt.executeQuery(query);  // ❌ Unhandled exceptions
    if (rs.next()) {
        return "Welcome, " + rs.getString("username");
    }
    return "User not found.";
}
```

**Issues:**
1. Stack trace exposed to users (information disclosure)
2. No specific error handling or recovery
3. Difficult debugging
4. Resources not properly released on error

### Solution: Specific Exception Handling

**Fixed Code:**
```java
@GetMapping("/getUser")
public String getUser(@RequestParam String username) {
    // ✓ Validate input first
    if (username == null || username.trim().isEmpty()) {
        logger.warn("Invalid username parameter received");
        return "Invalid username.";
    }

    try {
        String dbUrl = System.getenv("DB_URL") != null ? 
            System.getenv("DB_URL") : "jdbc:mysql://localhost:3306/appdb";
        String dbUser = System.getenv("DB_USER");
        String dbPassword = System.getenv("DB_PASSWORD");

        if (dbUser == null || dbPassword == null) {
            logger.error("Database credentials not configured in environment variables");
            return "System configuration error.";
        }

        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
            String query = "SELECT * FROM users WHERE username = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                pstmt.setString(1, username);
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        String returnUsername = rs.getString("username");
                        logger.info("User login attempt: {}", returnUsername);
                        return "Welcome, " + returnUsername;
                    }
                }
            }
        }
        
        logger.warn("User not found: {}", username);
        return "User not found.";

    } catch (SQLException e) {
        // ✓ Specific exception handling
        logger.error("Database error occurred", e);  // ✓ Logs full details for debugging
        return "An error occurred while processing your request.";  // ✓ Generic message to user
    } catch (Exception e) {
        // ✓ Catch unexpected errors
        logger.error("Unexpected error", e);
        return "An unexpected error occurred.";
    }
}
```

### Logging Best Practices

**Good - Security Conscious:**
```java
logger.info("User login attempt for username: {}", username);        // ✓ Logs action
logger.warn("Invalid input received: {}", sanitizedInput);           // ✓ Logs context
logger.error("Database connection failed", e);                       // ✓ Logs with exception for debugging
logger.debug("Query execution time: {} ms", elapsedTime);            // ✓ Debug info
```

**Bad - Information Disclosure:**
```java
logger.error("SQLException: " + e.getMessage());                     // ✗ Exposes error details
System.err.println(e.printStackTrace());                              // ✗ Stack trace to console
response.sendError(500, "Database connection failed: " + e);        // ✗ Error details to user
return "Error: " + e.getClass().getName() + ": " + e.getMessage(); // ✗ Exception to user
```

---

## Testing & Verification

### Static Code Analysis

```bash
# Check for SQL concatenation patterns
grep -n "SELECT.*+.*username" UserController_fixed.java

# Check for PreparedStatement usage
grep -n "PreparedStatement" UserController_fixed.java

# Check for hardcoded credentials
grep -nE "(password|password\s*=|api_key|secret)" UserController_fixed.java
```

### Manual Testing

**Test 1: SQL Injection Prevention**
```bash
# Test 1a: Basic injection
curl -X GET "http://localhost:8080/api/getUser?username=' OR '1'='1 --"
# Expected: User not found (not all users)

# Test 1b: UNION-based injection
curl -X GET "http://localhost:8080/api/getUser?username=' UNION SELECT password FROM users --"
# Expected: User not found (no injection)

# Test 1c: Time-based injection
curl -X GET "http://localhost:8080/api/getUser?username=' OR SLEEP(5) --"
# Expected: User not found (immediate response, no delay)
```

**Test 2: Special Characters Handling**
```bash
# Test with quotes
curl -X GET "http://localhost:8080/api/getUser?username=test%27s"
# Expected: Search for user "test's" works correctly

# Test with special SQL characters
curl -X GET "http://localhost:8080/api/getUser?username=test%25_%3b"
# Expected: Search for user "test%_;" works correctly
```

**Test 3: Environment Variables**
```bash
# Verify environment variables are loaded
ps aux | grep java | grep -o "DB_USER=.*"

# Check configuration in running application
curl http://localhost:8080/api/config  # If endpoint exists
```

### Automated Testing Script

```bash
#!/bin/bash

echo "Security Test Suite"
echo "==================="

# Test 1: Check for PreparedStatement
echo "Test 1: SQL Injection Prevention"
if grep -q "PreparedStatement" UserController_fixed.java; then
    echo "✓ PASS: PreparedStatement found"
else
    echo "✗ FAIL: PreparedStatement not found"
    exit 1
fi

# Test 2: Check for hardcoded API key
echo "Test 2: API Key Security"
if grep -q 'private static final String API_KEY = "sk-' input.java; then
    echo "✗ FAIL: Hardcoded API key found in original"
fi
if ! grep -q 'private static final String API_KEY = "sk-' UserController_fixed.java; then
    echo "✓ PASS: API key not hardcoded in fixed version"
else
    echo "✗ FAIL: API key still hardcoded"
    exit 1
fi

# Test 3: Check for environment variables
echo "Test 3: Secrets Management"
if grep -q "System.getenv" UserController_fixed.java; then
    echo "✓ PASS: Environment variables used"
else
    echo "✗ FAIL: Environment variables not used"
    exit 1
fi

echo ""
echo "All tests passed!"
```

---

## Deployment

### Pre-Deployment Checklist

- [ ] All source code reviewed for SQL injection patterns
- [ ] No hardcoded credentials in code or config files
- [ ] PreparedStatement used for all database queries
- [ ] Try-with-resources used for resource management
- [ ] Specific exception handling implemented
- [ ] Input validation added
- [ ] Logging configured without sensitive data
- [ ] Environment variables configured for deployment
- [ ] Database user account created with minimal permissions
- [ ] API key rotated if previously exposed
- [ ] Automated security tests passing
- [ ] Code reviewed by security team
- [ ] Dependencies scanned for vulnerabilities
- [ ] WAF/IDS rules configured for SQL injection patterns

### Secure Deployment

**1. Prepare Credentials**
```bash
# Generate strong passwords
openssl rand -base64 32  # For DB password
openssl rand -base64 48  # For API key

# Store in secrets management system (Vault, AWS Secrets Manager, etc.)
```

**2. Deploy Application**
```bash
# Docker example
docker run \
  --name secure-app \
  -e DB_URL="jdbc:mysql://db.example.com:3306/appdb" \
  -e DB_USER="appuser" \
  -e DB_PASSWORD="<generated_password>" \
  -e API_KEY="sk-<generated_key>" \
  secure-app:1.0
```

**3. Verify Deployment**
```bash
# Check logs for errors
docker logs secure-app

# Test endpoints
curl http://localhost:8080/api/getUser?username=test

# Monitor for SQL injection attempts
grep "Error\|Exception" app.log
```

---

## Additional Resources

- OWASP SQL Injection: https://owasp.org/www-community/attacks/SQL_Injection
- CWE-89: https://cwe.mitre.org/data/definitions/89.html
- Spring Security: https://spring.io/projects/spring-security
- JDBC Security: https://docs.oracle.com/javase/tutorial/jdbc/

---

**Implementation Complete** ✓

All vulnerabilities have been identified, fixed, and tested.
