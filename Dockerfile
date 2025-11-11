# Multi-stage Dockerfile for Spring Boot Application
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code
COPY *.java ./src/main/java/com/example/
COPY application.properties ./src/main/resources/

# Build the application
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy built JAR from build stage
COPY --from=build /app/target/*.jar app.jar

# Create logs directory
RUN mkdir -p /app/logs

# Expose Spring Boot default port
EXPOSE 8080

# Set environment variables (override in docker-compose or at runtime)
ENV DB_USERNAME=root
ENV DB_PASSWORD=password
ENV APP_API_KEY=sk-1234567890abcdef

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

