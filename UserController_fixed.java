// UserController.java - SECURE VERSION
package com.example.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.annotation.Autowired;
import javax.sql.DataSource;
import java.sql.*;

@RestController
@RequestMapping("/api")
public class UserController {
    // SECURITY FIX: API key loaded from environment variable instead of hardcoded
    @Value("${app.api.key}")
    private String apiKey;

    // SECURITY FIX: Use DataSource bean for database connections
    @Autowired
    private DataSource dataSource;

    @GetMapping("/getUser")
    public String getUser(@RequestParam String username) throws Exception {
        // SECURITY FIX: Use PreparedStatement with parameterized queries to prevent SQL injection
        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM users WHERE username = ?")) {
            
            // SECURITY FIX: Set parameter safely - prevents SQL injection
            pstmt.setString(1, username);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return "Welcome, " + rs.getString("username");
                }
                return "User not found.";
            }
        }
        // SECURITY FIX: Proper exception handling - don't expose sensitive information
        catch (SQLException e) {
            // Log error securely without exposing database structure
            throw new Exception("Database error occurred");
        }
    }
}

