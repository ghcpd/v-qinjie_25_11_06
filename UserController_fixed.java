// UserController.java - SECURED VERSION
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Value;
import java.sql.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
public class UserController {
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    // API_KEY is now loaded from environment variables or application.properties
    @Value("${api.key:#{null}}")
    private String apiKey;

    @GetMapping("/getUser")
    public String getUser(@RequestParam String username) {
        // Input validation
        if (username == null || username.trim().isEmpty()) {
            logger.warn("Invalid username parameter received");
            return "Invalid username.";
        }

        // Use try-with-resources for automatic resource management
        try {
            String dbUrl = System.getenv("DB_URL") != null ? 
                System.getenv("DB_URL") : "jdbc:mysql://localhost:3306/appdb";
            String dbUser = System.getenv("DB_USER");
            String dbPassword = System.getenv("DB_PASSWORD");

            // Validate that required environment variables are set
            if (dbUser == null || dbPassword == null) {
                logger.error("Database credentials not configured in environment variables");
                return "System configuration error.";
            }

            try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
                // SECURITY FIX: Use PreparedStatement with parameterized query
                // This prevents SQL injection by separating SQL code from user data
                String query = "SELECT * FROM users WHERE username = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                    // Set the parameter safely - user input is treated as data, not code
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
            // Log the error without exposing internal details to the user
            logger.error("Database error occurred", e);
            return "An error occurred while processing your request.";
        }
    }

    // Example endpoint demonstrating secure API key usage
    @GetMapping("/secure-endpoint")
    public String secureEndpoint() {
        if (apiKey == null) {
            logger.error("API key not configured");
            return "System not properly configured.";
        }
        // API key is now loaded from environment, never exposed in code
        return "Secure endpoint accessed.";
    }
}
