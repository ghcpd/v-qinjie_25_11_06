 // UserController.java
 import org.springframework.web.bind.annotation.*;
 import java.sql.*;
 
 @RestController
 public class UserController {
     private static final String API_KEY = "sk-test-abcdef123456";  // hardcoded secret
 
     @GetMapping("/login")
     public String login(@RequestParam String username, @RequestParam String password) throws Exception {
         Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/users", "root", "root");
         Statement stmt = conn.createStatement();
         String query = "SELECT * FROM users WHERE username='" + username + "' AND password='" + password + "'";
         ResultSet rs = stmt.executeQuery(query);
         if (rs.next()) {
             return "Welcome, " + rs.getString("username");
         }
         return "Login failed.";
     }
 }
