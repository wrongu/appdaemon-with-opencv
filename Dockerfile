FROM python:3.12-alpine

RUN apk add g++ gcc make git
RUN apk add python3-dev python3 py3-pip

# Install OpenCV and scikit-learn from Alpine packages to avoid having to build them
# from source, which is very slow and requires a lot of extra dependencies. However, this then
# requires patching the site-packages paths, which is handled in patch_python_path.sh below.
RUN apk add py3-scikit-learn py3-opencv
COPY patch_python_path.sh /patch_python_path.sh
RUN /bin/sh /patch_python_path.sh

RUN python3 -m venv /appdaemon/venv --system-site-packages
RUN /appdaemon/venv/bin/pip install --upgrade pip

# Use pip to install appdaemon, which is what the addon will run.
RUN /appdaemon/venv/bin/pip install --upgrade multidict appdaemon --no-build-isolation

# Copy everything from rootfs/whatever in this repo into /whatever in the container
COPY rootfs /

# Entry point for the container/addon will be to call launch.sh, which itself
# does some simple configuring before calling 'appdaemon -c /config'
WORKDIR /appdaemon
CMD ["/bin/sh", "launch.sh"]
