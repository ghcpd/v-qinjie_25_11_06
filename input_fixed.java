// UserController_fixed.java
import org.springframework.web.bind.annotation.*;
import java.sql.*;

@RestController
public class UserController {
    // No hardcoded secrets. Credentials must be provided via environment variables or application properties.

    @GetMapping("/getUser")
    public String getUser(@RequestParam String username) throws Exception {
        String url = System.getenv("DB_URL");
        String user = System.getenv("DB_USER");
        String pass = System.getenv("DB_PASS");
        if (url == null) { url = "jdbc:h2:mem:appdb"; }
        try (Connection conn = DriverManager.getConnection(url, user, pass);
             PreparedStatement stmt = conn.prepareStatement("SELECT username FROM users WHERE username = ?")) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return "Welcome, " + rs.getString("username");
                }
            }
        }
        return "User not found.";
    }
}
