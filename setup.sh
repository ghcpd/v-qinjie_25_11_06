#!/usr/bin/env bash
set -e

echo "Setting up Java project and building..."
# Ensure Maven is installed
mvn -q -v

# Build the project
mvn -q -DskipTests package

mkdir -p logs

echo "Setup complete. Build artifacts are in target/ and logs/ directory created."
