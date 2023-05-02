#!/bin/bash

# ----------------------------------------------------------------------------
# "THE BEER-WARE LICENSE" (Revision 42):
# darkl1nk wrote this script. As long as you retain this notice you
# can do whatever you want with this stuff. If we meet some day, and you think
# this stuff is worth it, you can buy me a beer in return.
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# This script securely records an audio stream from a remote device 
# through SSH for a specified duration and saves it in a specified format as 
# an audio file with timestamps. The underlying technology used for audio 
# processing is FFmpeg. The configuration for the remote device, 
# audio output settings, and other parameters are read from a config.ini file. 
# The script also supports command-line arguments to override 
# the duration, format values provided in the config.ini file, and scheduling.
# To use the script, simply run it with the desired duration (optional), 
# audio format (optional), and scheduling options (optional) as arguments: 
#
# Usage: ./record_stream.sh [-d duration] [-f audio_format] [-s schedule]
# Example: ./record_stream.sh -d 60 -f mp3 -s "now + 1 hour"
# ----------------------------------------------------------------------------

# Get the absolute path of the current script's directory
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Import library functions
source "${script_dir}/../lib/helper_functions.sh"
source "${script_dir}/../lib/ssh_utils.sh"
source "${script_dir}/../lib/audio_functions.sh"
source "${script_dir}/../lib/config_functions.sh"
source "${script_dir}/../lib/helper_functions.sh"
source "${script_dir}/../lib/logging_functions.sh"
source "${script_dir}/../lib/networking_functions.sh"
source "${script_dir}/../lib/scheduling_functions.sh"
source "${script_dir}/../lib/ssh_utils.sh"
source "${script_dir}/../lib/validation_functions.sh"

# =================================== Main ====================================

# Load configuration from the config.ini file
load_config "${script_dir}"
log_message "INFO" "============================================"
log_message "INFO" "Starting Secure Remote Audio Stream Recorder"
log_message "INFO" "============================================"

# Check requirements
check_required_commands

# Parse command line arguments
parse_arguments "$@"

# Validate and set values for command line arguments
validate_and_set_value "$duration" "${default_duration}" "validate_duration" "duration"
validate_and_set_value "$audio_format" "${default_format}" "validate_format" "audio_format"

# If the job is scheduled then we defer the execution of the script
if [ -n "$schedule" ]; then
  schedule_recording_job "$schedule" "$duration" "$audio_format" "$remote_ssh_server_ip" "$log_file"
  exit $?
fi

# Get start and end timestamps based on the duration
get_timestamps "${duration}"

# Generate unique ports for remote and local connections
generate_unique_ports

# Generate the filename of the output audio file
generate_audio_filename "${audio_output_directory}" "${start_timestamp}" "${end_timestamp}" "${audio_format}"

# Set up an SSH tunnel for secure communication
if ! setup_ssh_tunnel; then
  log_message "ERROR" "Unable to establish an SSH tunnel. Exiting..."
  exit 1
fi

# Set up a trap to clean up the SSH tunnel when the script exits
trap cleanup_ssh_tunnel EXIT

# Start listening to the audio stream and apply filters if configured
start_listening "$duration" "$audio_format" "$script_dir"

# Start emitting the audio stream from the remote device
if ! start_emission "${duration}" "${audio_format}" "${script_dir}"; then
  log_message "ERROR" "Unable to start emission on remote server. Exiting..."
  exit 1
fi
log_message "INFO" "Emission ended"
