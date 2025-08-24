# AppDaemon with OpenCV

This repository holds a custom experimental homeassistant addon. The addon behaves much like the appdaemon addon, except this one has the `cv2` OpenCV python package built-in. The reason to do this is because the standard AppDaemon addon `pip install`s packages at startup time, and it runs the startup routine each time the app py files are changed. Installing OpenCV takes upwards of 20 minutes. I don't want to wait 20 minutes to relaunch a script while iterating/developing.

## How-to local dev

Following [this guide](https://developers.home-assistant.io/docs/add-ons/testing/), the `.devcontainer` should in theory set up a locally-testable instance of homeassistant where the addon is locally available. Requires docker on the dev machine. Instance is at localhost:7123 on the dev machine.

## How-to install on Home Assistant OS

Simplest method is to open a terminal on the HAOS instance and do

```bash
$ cd /addons
$ git clone https://github.com/wrongu/appdaemon-with-opencv
```

Then go to the addon store and you should see it available as a local addon. Clicking install triggers a long docker build process (20+min). __Warning:__ click install once and leave it be. I crashed my whole HA system by trying to do a core update while this docker build was in progress. build Logs should be available in settings > logs > supervisor.

This setup results in two copies of the addon files on the HA instance:

1. `/addons/appdaemon-with-opencv`: a copy of the `<git repo>/addon` subdirectory, discoverable by the addon store
2. after build/installation of the addon, a new `/addon_configs/local_appdaemon_cv` directory will appear on the HA instance. When the addon container is run, this directory is mounted to `/config/`.

So, *from inside* the apps, refer to places like `/config/<whatever>/`, which actually points to `/addon_configs/local_appdaemon_cv/<whatever>/`, which is merely a *copy of* the initial `rootfs/` files found in `<git repo>/addon/rootfs/appdaemon/<whatever>/`.

__Note:__ building this addon takes 20+ minutes due to the OpenCV installation. This build time is paid whenever the supervisor rebuilds addons, which could be on system updates, etc. However, once built, it does accelerate the time to develop apps.

After installation, udpate the appdaemon config at `/addon_configs/local_appdaemon_cv/appdaemon.yaml`. Probably should make a backup after changing in case it gets overwritten later. (This *shouldn't* happen since the `launch.sh` script only copies the default-apps and default-config if they don't exist...)

## App-writing

Like classic AppDaemon, apps are python files located in `/addon_configs/local_appdaemon_cv/apps/whatever.py` and managed/configured in `/addon_configs/local_appdaemon_cv/apps/apps.yaml`.

## Extra python dependencies (experimental)

Adding a file to `/addon_configs/local_appdaemon_cv/apps/requirements.txt` (which maps to `/config/apps/requirements.txt` inside the AD docker container) should in theory trigger additional packages to be installed at startup time.
