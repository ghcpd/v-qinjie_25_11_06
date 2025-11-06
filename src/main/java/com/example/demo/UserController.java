package com.example.demo;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserController {
    private final JdbcTemplate jdbcTemplate;
    private final String apiKey;

    public UserController(JdbcTemplate jdbcTemplate, @Value("${app.apiKey:}") String apiKey) {
        this.jdbcTemplate = jdbcTemplate;
        this.apiKey = apiKey;
    }

    @GetMapping("/getUser")
    public ResponseEntity<String> getUser(@RequestParam String username) {
        // Use parameterized query to defend against SQL injection
        String sql = "SELECT username FROM users WHERE username = ?";
        try {
            String user = jdbcTemplate.queryForObject(sql, new Object[]{username}, String.class);
            return ResponseEntity.ok("Welcome, " + user);
        } catch (EmptyResultDataAccessException ex) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found.");
        } catch (Exception ex) {
            // Do not leak stack traces to the client
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Internal server error.");
        }
    }
}
