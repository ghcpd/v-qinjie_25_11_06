#!/usr/bin/env bash
# Detect platform and run the appropriate test script
OS=$(uname -s)
if [[ "$OS" =~ MINGW|CYGWIN|MSYS ]]; then
  echo "Windows-like environment detected. Running run_test.bat"
  cmd.exe /c run_test.bat
else
  echo "Unix-like environment detected. Running run_test.sh"
  ./run_test.sh
fi
