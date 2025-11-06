// UserController_fixed.java
import org.springframework.web.bind.annotation.*;
import java.sql.*;

@RestController
public class UserController {
    private static final String API_KEY = System.getenv("API_KEY");

    @GetMapping("/getUser")
    public String getUser(@RequestParam String username) throws Exception {
        String dbUrl = System.getenv("DB_URL");
        String dbUser = System.getenv("DB_USER");
        String dbPassword = System.getenv("DB_PASSWORD");
        Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
        PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE username = ?");
        stmt.setString(1, username);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            return "Welcome, " + rs.getString("username");
        }
        return "User not found.";
    }
}