#!/bin/bash

# ============================== Audio functions  =============================

# audio_functions.sh

generate_audio_filename() {
  local audio_output_directory=$1
  local start_timestamp=$2
  local end_timestamp=$3
  local audio_format=$4

  # Generate the filename of the output audio file
  raw_audio_file="${audio_output_directory}/${start_timestamp}_to_${end_timestamp}.${audio_format}"
}


get_audio_codec() {
  local audio_format=$1
  case "${audio_format}" in
    "mp3") echo "libmp3lame" ;;
    "ogg") echo "libvorbis" ;;
    "flac") echo "flac" ;;
    "wav") echo "pcm_s16le" ;;
  esac
  return 0
}

start_listening() {
  local duration=$1
  local audio_format=$2
  local script_dir=$3

  # Add noise reduction filter if enabled
  if [ "$noise_reduction_enabled" == "yes" ]; then
    filter_string+="silenceremove=1:0:${noise_reduction_level}dB"
  fi

  # Add equalization filter if enabled
  if [ "$equalization_enabled" == "yes" ]; then
    if [ -n "$filter_string" ]; then
      filter_string+="," # Separate filters with a comma
    fi
    filter_string+="equalizer=f=${equalization_frequency}:width_type=${equalization_width_type}:w=${equalization_width}:g=${equalization_gain}"
  fi

    # Base ffmpeg command
  local ffmpeg_command="ffmpeg -f ${audio_format} -i 'tcp://localhost:${local_port}?listen=1'"

  # Add filter string if not empty
  if [ -n "$filter_string" ]; then
    ffmpeg_command+=" -af '${filter_string}'"
  fi

  audio_codec=$(get_audio_codec "${audio_format}")
  if [ $? -ne 0 ]; then
    log_message "err" "Unsupported audio format: ${audio_format}"
    exit 1
  fi

  # Add remaining options
  ffmpeg_command+=" -t ${duration} -c:a ${audio_codec} ${audio_output_directory}/${start_timestamp}_to_${end_timestamp}.${audio_format} "

  # Execute ffmpeg command
  log_message "INFO" "Starting to listen on local server [[$(hostname)]]"
  log_message "INFO" "Saving audio file in: ${audio_output_directory}/${start_timestamp}_to_${end_timestamp}.${audio_format}"
  ffmpeg_listening_log_file="${script_dir}/../log/ffmpeg_listening.log"
  eval "$ffmpeg_command > '${ffmpeg_listening_log_file}' 2>&1 &"
  sleep 2
}

start_emission() {
  local duration=$1
  local audio_format=$2
  local script_dir=$3
  local timeout_command="timeout"
  local ssh_timeout=10

  audio_codec=$(get_audio_codec "${audio_format}")

  ffmpeg_emission_log_file="${script_dir}/../log/ffmpeg_emission.log"
  command="${timeout_command} ${duration} ffmpeg -f alsa -i default -acodec ${audio_codec} -ar 44100 -b:a 128k -f ${audio_format} tcp://localhost:${remote_port} &"

  log_message "INFO" "Starting emission on remote server [[${remote_ssh_server_ip}]]"
  ssh -o ConnectTimeout=${ssh_timeout} ${remote_ssh_user}@${remote_ssh_server_ip} "bash -c '$command'" > "${ffmpeg_emission_log_file}" 2>&1
  result=$?
  wait

  if [ $result -eq 0 ]; then
    log_message "INFO" "Emission started successfully on remote server [[${remote_ssh_server_ip}]]"
  else
    log_message "ERROR" "Failed to start emission on remote server [[${remote_ssh_server_ip}]]. Please check the connection and ensure the remote server is reachable."
    return 1
  fi
}

