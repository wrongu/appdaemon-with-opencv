ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest

FROM ${BUILD_FROM}

RUN apk add g++ gcc make git
RUN apk add python3-dev python3 py3-pip

RUN python3 -m venv /cv-app/venv
RUN /cv-app/venv/bin/pip install --upgrade pip

# Further env setup to allow OpenCV to build
RUN apk add build-base linux-headers samurai cmake
RUN /cv-app/venv/bin/pip install scikit-build numpy
# Installing OpenCV via pip in this environment requires "no build isolation" for
# setuptools/wheel to work properly. Do this once here so that, below, the
# `pip install -r requirements` doesn't try to reinstall opencv. Note: if
# opencv-python is a dependency listed in requirements.txt, its version must
# match the version installed above (OPENCV_PACKAGE arg sent to docker)
ARG OPENCV_PACKAGE=opencv-contrib-python-headless
RUN /cv-app/venv/bin/pip install $OPENCV_PACKAGE --no-build-isolation

# Copy all addon config root filestystem files into the container
COPY rootfs /

# Now actually install project requirements
COPY src /cv-app
RUN cd /cv-app && /cv-app/venv/bin/pip install -r requirements.txt
