#!/bin/bash

USER=${1:-jenkins}
# Check user is 'jenkins' or 'root' before to continue.
if ! [ "$USER" = "jenkins" ] && ! [ "$USER" = "root" ]; then
    echo "User is neither 'jenkins' nor 'root'. Exiting with status code 1."
    exit 1
fi

docker run --interactive --tty --privileged --user $USER android_emulator_image
