FROM openjdk:11-jre-slim

# Install MySQL client
RUN apt-get update && apt-get install -y mysql-client && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy application files
COPY UserController_fixed.java .
COPY pom.xml .
COPY src/ ./src/

# Set environment variables
ENV DB_URL=jdbc:mysql://mysql:3306/testdb
ENV DB_USER=testuser
ENV DB_PASSWORD=testpass
ENV API_KEY=your-secure-api-key-here

# Create logs directory
RUN mkdir -p logs

# Expose port
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "target/demo-0.0.1-SNAPSHOT.jar"]