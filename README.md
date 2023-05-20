# Secure Remote Audio Stream Recorder

![GitHub release (latest by date)](https://img.shields.io/github/v/release/darkl1nk/Secure-Remote-Audio-Stream-Recorder?style=flat-square)

## Contents of this README.md file

- [Project description](#project-description)
- [Features](#features)
- [Usage](#usage)
- [Project organization](#project-organization)
- [Prerequisites](#prerequisites)
- [Logging](#logging)
- [Setting up a WireGuard VPN between the local machine and the remote server](#setting-up-a-wireguard-vpn-between-the-local-machine-and-the-remote-server)
- [Alternative scheduling with cron](#alternative-scheduling-with-cron)


## Project description

This script is designed to record an audio stream of a specified duration and format from a remote device and save it as an audio file with timestamps. It establishes an SSH tunnel between the local machine and the remote device to ensure the audio stream is encrypted and secure during transmission. This not only maintains the privacy of the stream but also prevents unauthorized access to the audio data.

In addition to basic recording capabilities, the script offers audio filtering options to enhance the quality of the recorded audio and scheduling functionality for deferred recording. These include noise reduction, which helps minimize background noise and improve audio clarity, and equalization, which allows you to adjust the frequency balance of the audio to emphasize or de-emphasize certain frequencies. Scheduling options are provided using the `at` command, allowing you to set a specific time or delay for the script to start recording. This makes it suitable for a wide range of audio recording scenarios, from capturing podcasts and interviews to recording ambient sounds.

By using a configuration file, you can easily customize the script's behavior and audio filtering options without modifying the core code. This includes specifying the remote SSH user, server IP address, output directory, default recording duration, and audio format. The configuration file also enables you to toggle and adjust the noise reduction and equalization settings according to your specific needs.

By default, the script streams audio from the remote device's microphone. However, you can easily modify the `FFmpeg` emission command to stream audio from different sources. Below are some examples of different audio sources you can use with the `record_stream.sh` script.

1. **PulseAudio Monitor:** To stream audio from a `PulseAudio` monitor, replace the `-f alsa -i default` flags in the FFmpeg command with `-f pulse -i [monitor_name]`. You can find the available monitor names using the `pactl list sources` command.

2. **Audio file:** To stream an audio file, replace the `-f alsa -i default` flags with `-i [path_to_audio_file]`. Make sure the path is accessible from the remote device.

3. **URL stream:** To stream audio from a URL, replace the `-f alsa -i default` flags with `-i [url]`. Ensure that the URL is accessible from the remote device and contains a compatible audio stream.

Remember to test and adjust the FFmpeg command according to your specific use case and environment.

This script uses [FFmpeg](https://ffmpeg.org/) for audio processing.

## Features

- Record an audio stream from a remote device
- Specify the duration of the recording
- Choose the output format (MP3, WAV, OGG, or FLAC)
- Automatically generate unique filenames with timestamps
- Set up and manage SSH tunnels for secure communication

## Usage

```bash
./record_stream.sh [-d duration] [-f audio_format] [-s schedule]
```
   
* -d duration (optional): The duration of the recording in seconds. If not provided, the value from the config.ini file will be used.
* -f format (optional): The output format of the audio file (mp3, wav, ogg, flac). If not provided, the value from the config.ini file will be used.
* -s schedule (optional): Scheduling option for deferred recording, e.g., "now + 1 hour". If not provided, the script will start recording immediately.

Example:

```bash
./record_stream.sh -d 60 -f mp3 -s "now + 1 hour"
```

This will schedule an audio stream recording for 60 seconds and save it as an MP3 file with timestamps starting 1 hour from now.

Example:

```bash
./record_stream.sh -d 60 -f mp3 -s "14:00"
```

This will schedule an audio stream recording for 60 seconds and save it as an MP3 file with timestamps starting at 14:00.

If everything goes fine the output would look like this:

```
[2023-04-30 16:55:30] [INFO] ============================================
[2023-04-30 16:55:30] [INFO] Starting Secure Remote Audio Stream Recorder
[2023-04-30 16:55:30] [INFO] ============================================
[2023-04-30 16:55:30] [INFO] Check requirements on [[darklink]]
[2023-04-30 16:55:30] [INFO] Creating the SSH tunnel between [[darklink]] (port: 41173) and [[10.0.0.2]] (port: 36544)
[2023-04-30 16:55:31] [INFO] Starting listening on local server: [[darklink]]
[2023-04-30 16:55:31] [INFO] Saving audio file in: /home/darklink/Secure-Remote-Audio-Stream-Recorder/recordings/2023-04-30_16-55-30_to_2023-04-30_16-55-40.mp3
[2023-04-30 16:55:33] [INFO] Started listening script on [[darklink]].
[2023-04-30 16:55:33] [INFO] Starting emission on remote server [[10.0.0.2]]
[2023-04-30 16:55:46] [INFO] Emission ended
```

Or if you are scheduling the recording for later:

```
[2023-05-01 13:15:59] [INFO] ============================================
[2023-05-01 13:15:59] [INFO] Starting Secure Remote Audio Stream Recorder
[2023-05-01 13:15:59] [INFO] ============================================
[2023-05-01 13:15:59] [INFO] Check requirements on [[darklink]]
[2023-05-01 13:15:59] [INFO] Recording scheduled for 14:00
[2023-05-01 13:15:59] [INFO] Audio will be recorded from 10.0.0.2 and streamed to darklink
[2023-05-01 13:15:59] [INFO] You can check details in /home/darklink/Secure-Remote-Audio-Stream-Recorder/log/record_stream.log
```

To run the script from any location, you can configure your `PATH` variable as follows:

1. Add the script's directory to your `PATH` variable. For example, in your `.bashrc` or `.bash_profile`, add the following line, replacing `/path/to/script_directory` with the actual path:

```bash
export PATH=$PATH:/path/to/script_directory
```

2. Save the file and reload your terminal, or run `source ~/.bashrc` or `source ~/.bash_profile` to apply the changes.

Now you can run the `record_stream.sh` script from any location.

# Project Organization

This project follows a modular structure to make it easy to understand, maintain, and contribute to. Here's an overview of the organization and the purpose of each file and directory:

```
.
├── CONTRIBUTING.md
├── LICENSE.md
├── README.md
├── bin
│   └── record_stream.sh
├── config
│   └── config.ini
├── lib
│   ├── audio_functions.sh
│   ├── config_functions.sh
│   ├── helper_functions.sh
│   ├── logging_functions.sh
│   ├── networking_functions.sh
│   ├── scheduling_functions.sh
│   └── validation_functions.sh
├── log
│   ├── README.md
│   ├── ffmpeg_emission.log
│   ├── ffmpeg_listening.log
│   └── record_stream.log
└── recordings
    └── README.md
```

## Directories

- `bin`: Contains the main script to start recording and streaming audio.
- `config`: Stores the configuration file for the project.
- `lib`: Contains the shell scripts for various helper functions and utilities.
- `recordings`: This directory is where the recorded audio files are saved.
- `log`: Contains log files for the various processes involved in the recording and streaming of audio.

## Files

| Directory    | File                      | Description                                                              |
|--------------|---------------------------|--------------------------------------------------------------------------|
| `.`          | `CONTRIBUTING.md`         | Guidelines for contributing to the project.                              |
| `.`          | `LICENSE.md`              | License information for the project.                                     |
| `.`          | `README.md`               | Main README file with project information and instructions.              |
| `bin`        | `record_stream.sh`        | The main script to start recording and streaming audio.                  |
| `config`     | `config.ini`              | Configuration file containing settings for the project.                  |
| `lib`        | `audio_functions.sh`      | Functions related to audio processing.                                   |
|              | `config_functions.sh`     | Functions to read and parse the `config.ini` file.                       |
|              | `helper_functions.sh`     | General helper functions like logging, input validation, and scheduling. |
|              | `logging_functions.sh`    | Functions for logging messages, errors, and other information.           |
|              | `networking_functions.sh` | Functions related to network operations.                                 |
|              | `scheduling_functions.sh` | Functions to manage scheduling of the recording process.                 |
|              | `validation_functions.sh` | Functions to validate user inputs and configuration settings.            |
| `log`        | `README.md`               | Placeholder file to ensure directory structure in version control.       |
| `recordings` | `README.md`               | Placeholder file to ensure directory structure in version control.       |

## Prerequisites

To use this script, you need to have the following software installed on both the local machine and the remote device:

1. [FFmpeg](https://ffmpeg.org/download.html): A cross-platform solution to record, convert, and stream audio and video.
2. [OpenSSH](https://www.openssh.com/): A suite of secure networking utilities based on the Secure Shell (SSH) protocol.
3. (Optional) [at](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/at.html): A utility to schedule tasks for future execution. Required if you want to schedule the recording.

### Installation Instructions

#### Installing FFmpeg

##### Debian/Ubuntu

On Debian-based systems, you can install `FFmpeg` with the following command:

```bash
sudo apt-get update
sudo apt-get install ffmpeg
```

##### RedHat/CentOS/RockyLinux

For RedHat/CentOS systems, first enable the EPEL repository, and then install `FFmpeg` using the following commands:

```bash
sudo yum install epel-release
sudo yum install ffmpeg
```

##### FreeBSD

On FreeBSD, you can install FFmpeg with the following command:

```bash
pkg install multimedia/ffmpeg
```

##### OpenBSD

On OpenBSD, you can install FFmpeg with the following command:

```bash
pkg_add ffmpeg
```

#### Installing SSH

On the remote server you will need an active SSH server.

##### Debian/Ubuntu

On Debian-based systems, you can install the OpenSSH server with the following command:

```bash
sudo apt update
sudo apt install openssh-server
```

##### RedHat/CentOS/RockyLinux

For RedHat/CentOS/RockyLinux systems, you can install the OpenSSH server using the following commands:

```bash
sudo yum install openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd
```

##### BSD systems

On FreeBSD, you can install the OpenSSH server with the following command:

```bash
pkg install openssh-portable
```

To enable the OpenSSH server at startup, add the following line to the `/etc/rc.conf` file:

```
sshd_enable="YES"
```

Then start the OpenSSH server using the following command:

```bash
service sshd start
```

On OpenBSD, the OpenSSH server comes pre-installed and should be running by default.

#### Installing at (Optional, for scheduling)

##### Debian/Ubuntu

On Debian-based systems, you can install `at` with the following command:

```bash
sudo apt-get update
sudo apt-get install at
```

##### RedHat/CentOS/RockyLinux

For RedHat/CentOS systems, first enable the EPEL repository if not enabled, and then install `at` using the following commands:

```bash
sudo yum install epel-release
sudo yum install at
```

##### FreeBSD

On FreeBSD, you can install `at` with the following command:

```bash
pkg install at
```

##### OpenBSD

On OpenBSD, you can install `at` with the following command:

```bash
pkg_add at
```

### Configuration

A `config.ini` file is used for configuration settings, allowing users to set default values for variables such as remote SSH user, remote IP address, output format, and audio filtering options. If duration and format are provided as command-line arguments, their values in the `config.ini` file will be overridden.

Example `config.ini`:

```ini
remote_ssh_user=<remote_user_goes_here>
remote_ssh_server_ip=<remote_ip_address_goes_here>
audio_output_directory=<audio_files_go_here>
default_duration=60
default_format=mp3
log_file=../log/record_stream.log
noise_reduction_enabled=true
noise_reduction_level=20
equalization_enabled=true
equalization_frequency=1000
equalization_width_type=h
equalization_width=200
equalization_gain=10
```

#### Noise reduction

The script supports noise reduction using the `afftdn` filter in `FFmpeg`. This filter works by reducing noise in the frequency domain using the Adobe Audition-style noise reduction algorithm. The level parameter determines the amount of noise reduction applied to the audio signal, with higher values resulting in more noise reduction.

#### Equalization

Equalization is an audio processing technique used to adjust the balance between frequency components within an audio signal. The equalization filter in the script uses the `FFmpeg` equalizer filter, which allows you to specify a center frequency, gain, and bandwidth for the equalization operation. The frequency parameter sets the center frequency in Hertz, the width_type and width parameters define the bandwidth, and the gain parameter controls the amount of boost or cut applied to the specified frequency range in decibels.

In the example configuration file above, the equalization filter is set to boost the audio signal around 1000 Hz with a gain of 10 dB and a bandwidth of 200 Hz using the "H" (Hz) bandwidth type.

## Logging

The script logs its activities, including errors and important events, to a log file. The location and name of the log file can be configured in the `config.ini` file, under the `logging` section:

```ini
[logging]
log_file = ../log/record_stream.log
```
By default, the log file is stored in the log directory with the name `record_stream.log`. You can change the path and file name as needed. Make sure the specified directory exists and has the appropriate permissions for writing log files.

The log entries are formatted with a timestamp, log level (e.g., `INFO`, `ERROR`), and a message describing the event. You can use any log viewer or text editor to inspect the contents of the log file.

## Setting up a WireGuard VPN between the local machine and the remote server

If your remote server does not have a public IP address, you can set up a WireGuard VPN between the local machine and the remote server. This will allow secure communication between the devices. Follow the steps below for Debian/Ubuntu-based systems or Redhat/CentOS systems.

### Debian/Ubuntu-based systems

1. Install WireGuard on both the local machine and the remote server:

```bash
sudo apt update
sudo apt install wireguard
```

2. Generate public and private keys for both devices:

```bash
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
```

3. Configure the WireGuard interface on both devices:

- On the local machine, create a configuration file at `/etc/wireguard/wg0.conf` with the following content:

```ini
[Interface]
PrivateKey = LOCAL_MACHINE_PRIVATE_KEY
Address = LOCAL_MACHINE_VPN_IP/24
ListenPort = LOCAL_MACHINE_LISTEN_PORT

[Peer]
PublicKey = REMOTE_SERVER_PUBLIC_KEY
AllowedIPs = REMOTE_SERVER_VPN_IP/32
Endpoint = REMOTE_SERVER_PUBLIC_IP:REMOTE_SERVER_LISTEN_PORT
PersistentKeepalive = 25
```

- On the remote server, create a configuration file at `/etc/wireguard/wg0.conf` with the following content:

```ini
[Interface]
PrivateKey = REMOTE_SERVER_PRIVATE_KEY
Address = REMOTE_SERVER_VPN_IP/24
ListenPort = REMOTE_SERVER_LISTEN_PORT

[Peer]
PublicKey = LOCAL_MACHINE_PUBLIC_KEY
AllowedIPs = LOCAL_MACHINE_VPN_IP/32
PersistentKeepalive = 25
```

Start the WireGuard interface on both devices:

```bash
sudo wg-quick up wg0
```

5. Enable the WireGuard interface to start on boot:

```bash
sudo systemctl enable wg-quick@wg0
```

### Redhat/CentOS systems

1. Install the EPEL repository and WireGuard on both the local machine and the remote server:

```bash
sudo yum install epel-release
sudo yum install wireguard-dkms wireguard-tools
```

2. Follow the same steps 2 to 5 from the Debian/Ubuntu-based systems section, adjusting file paths and commands as necessary for Redhat/CentOS systems.

After completing the steps above, you should have a secure WireGuard VPN connection between your local machine and the remote server. Update the `remote_ssh_server_ip` variable in your `config.ini` file to use the remote server's VPN IP address.

## Alternative scheduling with cron

To orchestrate scheduled recordings, you can also use `cron`, a time-based job scheduler in Unix-like operating systems. `cron` allows you to run scripts at specified intervals, such as every minute, hourly, daily, or at specific times.

1. First, open your `crontab` file for editing by running:

```bash
crontab -e
```

2. Add a new line to schedule the `record_stream.sh` script with your desired frequency. Here are some examples:

- Run the script every day at 2:30 PM and record 1 hour of audio in MP3 format:

```
30 14 * * * /path/to/record_stream.sh -d 3600 -f mp3
```

- Run the script every Monday at 4:00 AM and record 30 minutes of audio in WAV format:

```
0 4 * * 1 /path/to/record_stream.sh -d 1800 -f wav
```

- Run the script on the 1st of every month at 12:00 PM and record 45 minutes of audio in OGG format:

```
0 12 1 * * /path/to/record_stream.sh -d 2700 -f ogg
```

Make sure to replace `/path/to/record_stream.sh` with the actual path to your script.

3. Save and exit the `crontab` file. The new scheduled job will now run at the specified interval.

Note: Ensure that the user running the `cron` job has the necessary permissions to execute the script and access the remote server.

