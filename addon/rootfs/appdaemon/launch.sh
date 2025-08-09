#!/bin/sh

# Presumably the first run: copy the default config into the /config directory which
# should be mounted by the HA docker host
if [ ! -f /config/appdaemon.yaml ]; then
  echo "No config file found; copying default config file from /appdaemon to /config"
  cp /appdaemon/appdaemon.yaml /config/appdaemon.yaml || exit 1
fi

if [ ! -d /config/apps ]; then
  echo "No apps directory found; copying default apps directory from /appdaemon to /config"
  cp -r /appdaemon/apps /config/apps || exit 1
fi

# Start the daemon
/appdaemon/venv/bin/appdaemon -c /config
