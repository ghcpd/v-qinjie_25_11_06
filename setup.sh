#!/usr/bin/env bash
set -e
echo "Ensure Maven is installed and Java 11+ is available"
if ! command -v mvn >/dev/null 2>&1; then
  echo "Maven not found. Please install Maven."
  exit 1
fi
if ! java -version >/dev/null 2>&1; then
  echo "Java not found. Please install Java 11+."
  exit 1
fi
echo "Environment appears to be ready."
