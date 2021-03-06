#!/usr/bin/env bash

function run() {
  cmd_output=$($1)
  return_value=$?
  if [ $return_value != 0 ]; then
    echo "Command '$1' failed"
    exit -1
  else
    echo "output: $cmd_output"
    echo "Command succeeded."
  fi
  return $return_value
}

cd /app/

sleep 1

run "python -u run_tests.py"

sleep 5

run "python -u test_session_test.py"
run "python -u test_session_auth_test.py"
