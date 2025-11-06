// UserController.java
import org.springframework.web.bind.annotation.*;
import java.sql.*;

@RestController
public class UserController {
    private static final String API_KEY = "sk-1234567890abcdef";  // hardcoded secret

    @GetMapping("/getUser")
    public String getUser(@RequestParam String username) throws Exception {
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/appdb", "root", "password");
        Statement stmt = conn.createStatement();
        String query = "SELECT * FROM users WHERE username = '" + username + "'";
        ResultSet rs = stmt.executeQuery(query);
        if (rs.next()) {
            return "Welcome, " + rs.getString("username");
        }
        return "User not found.";
    }
}
