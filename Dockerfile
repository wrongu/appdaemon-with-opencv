FROM python:3.12-alpine

RUN apk add g++ gcc make git
RUN apk add python3-dev python3 py3-pip

RUN python3 -m venv /appdaemon/venv
RUN /appdaemon/venv/bin/pip install --upgrade pip

# Further env setup to allow OpenCV to build
RUN apk add build-base linux-headers samurai cmake
RUN /appdaemon/venv/bin/pip install scikit-build numpy
# Installing OpenCV via pip in this environment requires "no build isolation" for
# setuptools/wheel to work properly. Do this once here so that, below, the
# `pip install -r requirements` doesn't try to reinstall opencv. Note: if
# opencv-python is a dependency listed in requirements.txt, its version must
# match the version installed above (OPENCV_PACKAGE arg sent to docker)
ARG OPENCV_PACKAGE=opencv-contrib-python-headless
RUN /appdaemon/venv/bin/pip install $OPENCV_PACKAGE --no-build-isolation

# Use pip to install appdaemon, which is what the addon will run.
RUN /appdaemon/venv/bin/pip install --upgrade multidict appdaemon --no-build-isolation

# Clean up: remove extra build dependencies that would just bloat the image
RUN apk del build-base linux-headers samurai cmake

# Copy everything from rootfs/whatever in this repo into /whatever in the container
COPY rootfs /

# Entry point for the container/addon will be to call launch.sh, which itself
# does some simple configuring before calling 'appdaemon -c /config'
WORKDIR /appdaemon
CMD ["/bin/sh", "launch.sh"]
