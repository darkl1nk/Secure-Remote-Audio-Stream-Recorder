#!/bin/bash

# ============================== Config Functions =============================

load_config() {
  local script_dir=$1

  if [ -f "${script_dir}/../config/config.ini" ]; then
    while IFS="=" read -r key value; do
      case "$key" in
        remote_ssh_user) remote_ssh_user="$value" ;;
        remote_ssh_server_ip) remote_ssh_server_ip="$value" ;;
	monitoring_address) monitoring_address="$value";;
        audio_output_directory) audio_output_directory=$(realpath "${script_dir}/${value}") ;;
        default_duration) default_duration="$value" ;;
        default_format) default_format="$value" ;;
        log_file) 
          if [[ $value == /* ]]; then
            log_file="$value"
          else
            log_file=$(realpath "${script_dir}/${value}")
          fi
        ;;
	noise_reduction_enabled) noise_reduction_enabled="$value" ;;
        noise_reduction_level) noise_reduction_level="$value" ;;
        equalization_enabled) equalization_enabled="$value" ;;
        equalization_frequency) equalization_frequency="$value" ;;
        equalization_width_type) equalization_width_type="$value" ;;
        equalization_width) equalization_width="$value" ;;
        equalization_gain) equalization_gain="$value" ;;
        *) log_message "ERROR" "Unknown key '$key'" ;;
      esac
    done < "${script_dir}/../config/config.ini"
  else
    log_message "ERROR" "config.ini not found"
    exit 1
  fi
}


