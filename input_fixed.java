// UserController_fixed.java
import org.springframework.web.bind.annotation.*;
import javax.sql.DataSource;
import java.sql.*;

@RestController
public class UserController_fixed_original {
    private final DataSource dataSource;

    public UserController_fixed_original(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @GetMapping("/login")
    public String login(@RequestParam String username, @RequestParam String password) throws Exception {
        if (username == null || username.length() > 100 || password == null || password.length() > 100) {
            return "Invalid input.";
        }
        String sql = "SELECT username FROM users WHERE username = ? AND password = ?";
        try (Connection conn = dataSource.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return "Welcome, " + rs.getString("username");
                }
            }
        }
        return "Login failed.";
    }
}
