#!/usr/bin/env bash
OS=
case "$(uname -s)" in
  Linux*) OS=Linux ;;
  Darwin*) OS=Mac ;;
  CYGWIN*|MINGW32*|MSYS*|MINGW*) OS=Windows ;;
  *) OS="Unknown" ;;
esac

mkdir -p logs
if [ "$OS" = "Windows" ]; then
  echo "Detected Windows"
  powershell.exe -Command .\\run_test.bat | tee logs/test_run.log
else
  echo "Detected $OS"
  ./run_test.sh | tee logs/test_run.log
fi
