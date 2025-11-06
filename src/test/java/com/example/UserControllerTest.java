package com.example;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.web.server.LocalServerPort;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.http.ResponseEntity;

import java.sql.Connection;
import java.sql.Statement;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
public class UserControllerTest {
    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private javax.sql.DataSource dataSource;

    @Test
    public void testSqlInjectionNotAllowed() throws Exception {
        // Insert a known user
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute("CREATE TABLE IF NOT EXISTS users (username VARCHAR(100));");
            stmt.execute("DELETE FROM users;");
            stmt.execute("INSERT INTO users (username) VALUES ('john');");
        }

        // Try a SQL injection payload
        String payload = "' OR '1'='1";
        ResponseEntity<String> response = restTemplate.getForEntity("http://localhost:" + port + "/getUser?username=" + java.net.URLEncoder.encode(payload, "UTF-8"), String.class);
        assertThat(response.getStatusCodeValue()).isEqualTo(200);
        assertThat(response.getBody()).contains("User not found");
    }
}
