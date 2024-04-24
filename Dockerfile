FROM gradle:jdk17-jammy

# Create non-root user with identical host uid/gid.
# It will helps with permissions on shared volumes.
ARG HOST_UID
ARG HOST_GID
RUN groupadd --gid $HOST_GID jenkins && \
    useradd --no-log-init --system --uid $HOST_UID --gid jenkins jenkins --create-home

# Install depedencies.
#    - Emulation dependencies
#    - Virtualization dependencies
RUN apt-get update && \ 
    apt-get install --yes \
    	libx11-6 \
    	libpulse0 \
    	libgl1 \
    	libnss3 \
    	libxcomposite1 \
    	libxcursor1 \
    	libxdamage1 \
    	libxi6 libxtst6 \
    	libasound2

USER jenkins

ARG WORKDIR="/home/jenkins"
WORKDIR $WORKDIR

# Links.
ARG ANDROID_CMD="commandlinetools-linux-11076708_latest.zip"

# Environment variables.
ENV JAVA_HOME=/opt/java/openjdk
ENV ANDROID_SDK_ROOT="$WORKDIR/.android_sdk"
ENV ANDROID_AVD_HOME="$WORKDIR/.android/avd"
ENV PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools"

# Download and install android SDK Command-Line Tools.
RUN wget https://dl.google.com/android/repository/${ANDROID_CMD} --directory-prefix /tmp && \
    unzip -d $ANDROID_SDK_ROOT /tmp/$ANDROID_CMD

# Accept sdkmanager licences../r
RUN yes Y | $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --licenses --sdk_root=$ANDROID_SDK_ROOT

# Get latest android SDK Command-Line Tools.
# Then, the sdkmanager should be able to recognize the SDK location, and you won't need to provide the sdk_root flag.
RUN $ANDROID_SDK_ROOT/cmdline-tools/bin/sdkmanager --no_https --sdk_root=$ANDROID_SDK_ROOT "cmdline-tools;latest"

# Install everything needed for android emulator.
# Disable https to try to be faster.
RUN sdkmanager --no_https "platforms;android-33" "build-tools;33.0.2"
RUN sdkmanager --no_https "extras;google;m2repository" "extras;android;m2repository"
RUN sdkmanager --no_https "platform-tools" "tools"
RUN sdkmanager --no_https "system-images;android-33;google_apis_playstore;x86_64"

# Create Android Virtual Device (AVD).
ARG EMULATOR_NAME="device"
ENV EMULATOR_NAME=$EMULATOR_NAME
RUN avdmanager create avd --name "${EMULATOR_NAME}" --device pixel --package "system-images;android-33;google_apis_playstore;x86_64"

COPY --chown=1003:1003 emulator_run.sh $WORKDIR/emulator_run.sh

USER root
RUN apt-get update && \ 
    apt-get install --yes \
			libtcmalloc-minimal4
USER jenkins
CMD [ "/bin/bash" ]
