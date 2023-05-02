#!/bin/bash

# ============================== Networking Functions =============================

is_port_available() {
  port=$1
  (echo >/dev/tcp/127.0.0.1/$port) >/dev/null 2>&1
  if [ $? -eq 0 ]; then
    return 1  # Port is in use, return non-zero (failure)
  else
    return 0  # Port is available, return zero (success)
  fi
}

generate_port() {
  port=$((RANDOM % 55536 + 10000))
  while ! is_port_available $port; do
    port=$((RANDOM % 55536 + 10000))
  done
  echo $port
}

generate_unique_ports() {
  remote_port=$(generate_port)
  local_port=$(generate_port)
}


