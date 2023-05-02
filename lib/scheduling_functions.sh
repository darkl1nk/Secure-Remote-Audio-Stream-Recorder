#!/bin/bash

# ============================== Scheduling functions  =============================

schedule_recording() {
  local schedule=$1
  local script_to_run=$2

  if ! echo "${script_to_run}" | at "${schedule}" >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

schedule_recording_job() {
  local schedule=$1
  local duration=$2
  local audio_format=$3
  local remote_ssh_server_ip=$4
  local log_file=$5
  local script_dir=$(dirname "$(readlink -f "$0")")

  validate_schedule "$schedule"
  if [ $? -ne 0 ]; then
    return 1
  fi

  local record_stream_script="${script_dir}/record_stream.sh -d ${duration} -f ${audio_format}"
  if schedule_recording "${schedule}" "${record_stream_script}"; then
    log_message "INFO" "Recording scheduled for ${schedule}"
    log_message "INFO" "\e[1;31mAudio will be recorded from ${remote_ssh_server_ip} and streamed to $(hostname)\e[0m"
    log_message "INFO" "You can check details in the ${log_file}"
    return 0
  else
    log_message "ERROR" "Failed to schedule the script. Please check your 'at' command syntax."
    return 1
  fi
}


