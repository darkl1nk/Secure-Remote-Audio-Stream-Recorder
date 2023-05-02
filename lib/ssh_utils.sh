#!/bin/bash

# ============================== SSH Utils  ================================

setup_ssh_tunnel() {
  local ssh_timeout=10

  log_message "INFO" "Creating the SSH tunnel between [[$(hostname)]] (port: ${local_port}) and [[${remote_ssh_server_ip}]] (port: ${remote_port})"

  # Test if the remote server is reachable before setting up the SSH tunnel
  if ! ssh -o ConnectTimeout=${ssh_timeout} -q ${remote_ssh_user}@${remote_ssh_server_ip} exit; then
    log_message "ERROR" "SSH connection to ${remote_ssh_server_ip} failed. Please check the connection and ensure the remote server is reachable."
    return 1
  fi

  # Set up the SSH tunnel
  ssh -f -o ConnectTimeout=${ssh_timeout} -N -R ${remote_port}:localhost:${local_port} ${remote_ssh_user}@${remote_ssh_server_ip}

  if [ $? -ne 0 ]; then
    log_message "ERROR" "Failed to create the SSH tunnel. Please check the connection and ensure the remote server is reachable."
    return 1
  fi
}

cleanup_ssh_tunnel() {
  log_message "INFO" "Removing SSH tunnel"
  ssh_tunnel_pid=$(pgrep -f "ssh -f -o ConnectTimeout=[0-9]+ -N -R ${remote_port}:localhost:${local_port}")

  if [ -n "$ssh_tunnel_pid" ]; then
    kill "$ssh_tunnel_pid"
  fi
}

