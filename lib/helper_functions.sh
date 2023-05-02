#!/bin/bash

# ============================== Helper Functions =============================

show_help() {
  echo "Usage: $0 <duration> <format>"
  echo "Example: $0 60 mp3"
  echo "Records an audio stream of the specified duration (in seconds) from a remote device and saves it as an audio file with timestamps in the specified format (mp3, wav, ogg, flac)."
}

parse_arguments() {
  while getopts "d:f:s:" opt; do
    case $opt in
      d) duration="$OPTARG" ;;
      f) audio_format="$OPTARG" ;;
      s) schedule="$OPTARG" ;;
      \?) echo "Usage: ./record_stream.sh -d [duration] -f [audio_format] [-s schedule]"
          exit 1
          ;;
    esac
  done
}

check_required_commands() {
  local commands=("ffmpeg" "timeout" "ssh" "logger")

  log_message "INFO" "Check requirements on [[$(hostname)]]"

  for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      log_message "ERROR" "$cmd is not installed or not in the PATH"
      exit 1
    fi
  done
}

get_timestamps() {
  local duration=$1
  start_timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
  end_timestamp=$(date -d "+${duration} seconds" '+%Y-%m-%d_%H-%M-%S')
}

