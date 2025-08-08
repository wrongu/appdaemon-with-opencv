#!/cv-app/venv/bin/python
import time
import os


if __name__ == "__main__":
    print("Hello from the app. CWD is", os.getcwd())

    possible_config_files = [
        "/config/config.yaml",
        "/config/lightweight_camera_monitor.yaml",
        "/config/appdaemon.yaml",
        "/data/options.json",
    ]

    for config_file in possible_config_files:
        if os.path.exists(config_file):
            print("Found config file:", config_file)
            break
    else:
        print("No config file found.")

    while True:
        print("pollin'")
        time.sleep(5)
