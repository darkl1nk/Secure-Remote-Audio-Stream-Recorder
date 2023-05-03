import sys
import os
import subprocess
from PyQt5.QtWidgets import QApplication, QWidget, QVBoxLayout, QLabel, QLineEdit, QPushButton, QCheckBox, QTextEdit, QComboBox, QDateTimeEdit
from PyQt5.QtCore import QDateTime


class Application(QWidget):
    def __init__(self):
        super().__init__()

        # Set up the user interface
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle("Secure Remote Audio Stream Recorder")

        layout = QVBoxLayout()

        self.remote_ip_label = QLabel("Remote IP:")
        layout.addWidget(self.remote_ip_label)

        self.remote_ip_entry = QLineEdit()
        layout.addWidget(self.remote_ip_entry)

        self.duration_label = QLabel("Duration (seconds):")
        layout.addWidget(self.duration_label)

        self.duration_entry = QLineEdit()
        layout.addWidget(self.duration_entry)

        self.audio_format_label = QLabel("Audio Format:")
        layout.addWidget(self.audio_format_label)

        self.audio_format_combobox = QComboBox()
        self.audio_format_combobox.addItem("MP3")
        self.audio_format_combobox.addItem("WAV")
        self.audio_format_combobox.addItem("OGG")
        self.audio_format_combobox.addItem("FLAC")
        layout.addWidget(self.audio_format_combobox)

        self.schedule_label = QLabel("Schedule (Leave empty for immediate start):")
        layout.addWidget(self.schedule_label)

        self.schedule_datetime = QDateTimeEdit()
        self.schedule_datetime.setDateTime(QDateTime.currentDateTime())
        layout.addWidget(self.schedule_datetime)

        self.start_button = QPushButton("Start Recording")
        self.start_button.clicked.connect(self.start_recording)
        layout.addWidget(self.start_button)

        self.stop_button = QPushButton("Stop Recording")
        self.stop_button.clicked.connect(self.stop_recording)
        layout.addWidget(self.stop_button)

        self.output_text = QTextEdit()
        layout.addWidget(self.output_text)

        self.setLayout(layout)

        self.setMinimumSize(300, 300)
        self.setMaximumSize(800, 600)

    def start_recording(self):
        remote_ip = self.remote_ip_entry.text()
        duration = self.duration_entry.text()
        audio_format = self.audio_format_combobox.currentText().lower()
        schedule = self.schedule_datetime.text()

        # Implement the logic for starting the recording here
        command = f"../bin/record_stream.sh -d {duration} -f {audio_format} -s '{schedule}'"
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        output, error = process.communicate()

        self.output_text.append("Recording started...\n")
        self.output_text.append(output.decode())
        self.output_text.append(error.decode())

    def stop_recording(self):
        # Implement the logic for stopping the recording here
        self.output_text.append("Recording stopped.\n")


def main():
    app = QApplication(sys.argv)
    application = Application()
    application.show()
    sys.exit(app.exec_())


if __name__ == "__main__":
    main()

