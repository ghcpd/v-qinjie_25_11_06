#!/usr/bin/env bash
set -euo pipefail

# Install dependencies (Debian/Ubuntu)
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk maven git

# Build the project
mvn -q -DskipTests package

# Run tests
mvn -q test | tee -a logs/test_run.log
