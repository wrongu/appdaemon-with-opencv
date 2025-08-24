# AppDaemon with OpenCV

This repository holds a custom experimental homeassistant addon. The addon behaves much like the appdaemon addon, except this one has the `cv2` OpenCV python package built-in. The reason to do this is because the standard AppDaemon addon `pip install`s packages at startup time, and it runs the startup routine each time the app py files are changed. Installing OpenCV takes upwards of 20 minutes. I don't want to wait 20 minutes to relaunch a script while iterating/developing.

## How-to local dev

Following [this guide](https://developers.home-assistant.io/docs/add-ons/testing/), the `.devcontainer` should in theory set up a locally-testable instance of homeassistant where the addon is locally available. Requires docker on the dev machine. Instance is at localhost:7123 on the dev machine.

## How-to install on Home Assistant OS

Get a copy (ftp, git, whatever) of this repo's `addon` directory onto the machine running HA. The HA supervisor looks for addon-like things in `/addons/`. I found that HA doesn't seem to like symlinks, which adds a few steps... How I have it set up:

1. cloned this git repo to `/config/code/appdaemon-with-opencv`
2. copied `/config/code/appdaemon-with-opencv/addon` to `/addons/appdaemon-with-opencv`

If setup correctly, opening the HA landing page and going to settings > addons > store (and maybe "check for updates") should result in this addon appearing as a local option at the top.

__Note:__ building this addon takes 20+ minutes due to the OpenCV installation. This build time is paid whenever the supervisor rebuilds addons, which could be on system updates, etc. However, once built, it does accelerate the time to develop apps.

After installation, udpate the appdaemon config at `/addon_configs/local_appdaemon_cv/appdaemon.yaml`. Probably should make a backup after changing in case it gets overwritten later. (This *shouldn't* happen since the `launch.sh` script only copies the default-apps and default-config if they don't exist...)

## App-writing

Like classic AppDaemon, apps are python files located in `/addon_configs/local_appdaemon_cv/apps/whatever.py` and managed/configured in `/addon_configs/local_appdaemon_cv/apps/apps.yaml`.

## Extra python dependencies (experimental)

Adding a requirements.txt file to `/addon_configs/local_appdaemon_cv/apps/` (which maps to `/config/apps/` inside the AD docker container) should in theory trigger additional packages to be installed at startup time.