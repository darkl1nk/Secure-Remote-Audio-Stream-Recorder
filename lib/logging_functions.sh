#!/bin/bash

# ============================== Logging Functions =============================

log_message() {
  local log_level=$1
  local message=$2
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local log_entry="[$timestamp] [$log_level] $message"
  echo -e "${log_entry}" | tee -a "${log_file}"
  logger -p user.$log_level -t "record_stream" "${log_entry}"
}

