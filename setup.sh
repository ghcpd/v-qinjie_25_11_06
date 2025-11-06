#!/bin/bash
# setup.sh - Linux/macOS setup script

echo "Setting up Java Spring Boot Security Test Environment..."

# Install Java 11 if not present
if ! command -v java &> /dev/null; then
    echo "Installing Java 11..."
    sudo apt-get update
    sudo apt-get install -y openjdk-11-jdk
fi

# Install Maven if not present
if ! command -v mvn &> /dev/null; then
    echo "Installing Maven..."
    sudo apt-get install -y maven
fi

# Install MySQL client for testing
if ! command -v mysql &> /dev/null; then
    echo "Installing MySQL client..."
    sudo apt-get install -y mysql-client
fi

# Create project directory structure
mkdir -p src/main/java/com/example/demo
mkdir -p src/test/java/com/example/demo
mkdir -p logs

# Set environment variables
export DB_URL="jdbc:mysql://localhost:3306/testdb"
export DB_USER="testuser"
export DB_PASSWORD="testpass"
export API_KEY="your-secure-api-key-here"

echo "Environment setup complete!"
echo "Please ensure MySQL is running and testdb database exists"
echo "Run ./run_test.sh to execute security tests"