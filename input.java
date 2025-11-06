// UserController.java (SECURE version)
import org.springframework.web.bind.annotation.*;
import java.sql.*;

@RestController
public class UserController {
    // Retrieve API key from environment or config - never hardcode
    private static final String API_KEY = System.getenv("APP_API_KEY");

    @GetMapping("/getUser")
    public String getUser(@RequestParam String username) throws Exception {
        // Input validation — allow only short alphanumeric usernames (adjust regex to your policy)
        if (username == null || !username.matches("[A-Za-z0-9_\-]{1,50}")) {
            return "Invalid username";
        }

        String dbUrl = System.getenv().getOrDefault("DB_URL", "jdbc:mysql://localhost:3306/appdb");
        String dbUser = System.getenv().getOrDefault("DB_USER", "root");
        String dbPass = System.getenv().getOrDefault("DB_PASS", "");

        String query = "SELECT username FROM users WHERE username = ?";
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "Welcome, " + rs.getString("username");
                }
            }
        }
        return "User not found.";
    }
}
