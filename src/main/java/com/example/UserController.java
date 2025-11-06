package com.example;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
public class UserController {
    @Value("${APP_API_KEY:}")
    private String apiKey;

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public UserController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/getUser")
    public String getUser(@RequestParam String username) {
        String sql = "SELECT username FROM users WHERE username = ?";
        List<String> users = jdbcTemplate.query(sql, new Object[] { username }, (rs, rowNum) -> rs.getString("username"));
        if (!users.isEmpty()) {
            return "Welcome, " + users.get(0);
        }
        return "User not found.";
    }
}
