# Use official Maven image to build the Java application
FROM maven:3.8.1-openjdk-11 AS builder

WORKDIR /build

# Copy source files
COPY UserController_fixed.java .
COPY pom.xml .

# Build the application
RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:11-jre-slim

WORKDIR /app

# Copy built JAR from builder
COPY --from=builder /build/target/*.jar app.jar

# Set environment variables for secure configuration
ENV DB_URL=jdbc:mysql://db:3306/appdb
ENV DB_USER=appuser
ENV DB_PASSWORD=secure_password
ENV API_KEY=sk-secure-key-from-vault

# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
