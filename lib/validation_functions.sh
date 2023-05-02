#!/bin/bash

# ============================== Validation functions =============================

validate_and_set_value() {
  local provided_value=$1
  local default_value=$2
  local validation_function=$3
  local result_variable=$4

  if [ -n "$provided_value" ]; then
    $validation_function "$provided_value"
    if [ $? -ne 0 ]; then
      exit 1
    fi
    eval "$result_variable='$provided_value'"
  else
    $validation_function "$default_value"
    if [ $? -ne 0 ]; then
      exit 1
    fi
    eval "$result_variable='$default_value'"
  fi
}

validate_format() {
  if [ -z "$1" ] || ! [[ "$1" =~ ^(mp3|wav|ogg|flac)$ ]]; then
    log_message "ERROR" "Unsupported format ${audio_format}"
    return 1
  fi
  return 0
}

validate_duration() {
  if [ -z "$1" ] || ! [[ "$1" =~ ^[0-9]+$ ]]; then
    log_message "ERROR" "Please provide a valid integer duration as an argument."
    return 1
  fi
  return 0
}

validate_schedule() {
  local schedule="$1"

  if [[ -n "$schedule" ]]; then
    echo "echo test" | at "$schedule" 2>/dev/null
    if [[ $? -ne 0 ]]; then
      log_message "ERROR" "Invalid schedule format: $schedule"
      return 1
    else
      # Remove the last scheduled 'at' job
      atq | tail -n 1 | awk '{print $1}' | xargs atrm
    fi
  fi
  return 0
}

